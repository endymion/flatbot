require 'csv'
require 'awesome_print'
require 'google_maps_service'
require 'daybreak'
require 'liquid'

class Flatbot

  def inspect(start, finish)

    route_name =
      @options['name'] ||
      "#{Flatbot::Coordinate.filename_from_string(start)}-to-" +
        "#{Flatbot::Coordinate.filename_from_string(finish)}"
    puts "Flatbot is seeking " + "joy".green +
      " and watching for " + "pain".red + " along " +
      route_name

    @progressbar = ProgressBar.create(
      total: 0,
      autofinish: false,
      format: "Flatbot has inspected: %c of %C path segments.  %a %e %P%"
    )

    gmaps = GoogleMapsService::Client.new(
      key: ENV['GOOGLE_MAPS_API_KEY'])

    routes = gmaps.directions(
      Flatbot::Coordinate.from_string(start),
      Flatbot::Coordinate.from_string(finish),
      mode: 'bicycling',
      avoid: ['highways', 'tolls', 'ferries'],
      units: 'metric',
      alternatives: false)

    # Count the total number of locations for the progress bar.
    # @progressbar.total = 0
    routes[0][:legs].each do |leg|
      leg[:steps].each do |step|
        @progressbar.total +=
          Polylines::Decoder.decode_polyline(step[:polyline][:points]).length - 1
      end
    end

    inclines = []
    @coordinates_db = Daybreak::DB.new 'coordinates.db'

    maximum_slope_percentage = 0
    minimum_slope_percentage = 0
    routes[0][:legs].each do |leg|
      leg[:steps].each do |step|

        locations =
          Polylines::Decoder.decode_polyline(step[:polyline][:points])

        (locations.length - 1).times do |i|
          from_location = locations[i]
          to_location = locations[i+1]

          # Key for caching coordinates.
          db_key = from_location.to_s + to_location.to_s +
            @options['interpolations'].to_s

          interpolated_locations_with_elevation_this_step =
            # Check to see if these coordinates were already cached?
            if @coordinates_db.keys.include? db_key
              @coordinates_db[db_key]
            else
              if @options['verbose']
                @progressbar.log 'Google Maps API call.'.yellow
              end
              @coordinates_db[db_key] =
                gmaps.elevation_along_path([from_location, to_location],
                  # Google Maps wants the total nubmer of
                  # interpolated points, including the first
                  # and last.
                  @options['interpolations'] + 2
                ).flatten
            end

          inclines <<
            inclines(interpolated_locations_with_elevation_this_step)
          inclines.flatten!

          inclines.each do |incline|
            maximum_slope_percentage = incline[:slope_percentage] if
              incline[:slope_percentage] > maximum_slope_percentage
            minimum_slope_percentage = incline[:slope_percentage] if
              incline[:slope_percentage] < minimum_slope_percentage
          end

          @progressbar.increment

        end
      end
    end

    @coordinates_db.close
    @progressbar.stop

    # Output CSV file.
    if @options['output']
      puts "Writing CSV data to #{@options['output']}"
      CSV.open(@options['output'], 'wb') do |csv|
        csv << [
          'latitude',
          'longitude',
          'elevation',
          'incline'
        ]
        inclines.flatten.each do |incline|
          csv << [
            incline[:location][:lat],
            incline[:location][:lng],
            incline[:elevation],
            incline[:slope_percentage]
          ]
        end
      end
    end

    puts "Steepest uphill: " + maximum_slope_percentage.round(2).to_s.blue
    puts "Steepest downhill: " + minimum_slope_percentage.round(2).to_s.blue

    filename = @options['report'].gsub(/(\.[^\.]+)$/, ' - ' + route_name + '\1')
    puts "Writing report to: " + filename.blue

    template_parameters = {
      'route_name' => route_name,
      'steepest_uphill' => maximum_slope_percentage.round(2).to_s,
      'steepest_downhill' => minimum_slope_percentage.round(2).to_s,
      'uphill_slope_warning' => maximum_slope_percentage > @options['threshold'].to_f,
      'downhill_slope_warning' => minimum_slope_percentage < -@options['threshold'].to_f,
      'threshold' => @options['threshold'],
      'elevation_chart_data' =>
        inclines.map.with_index {
          |incline, idx| "[#{idx},#{incline[:elevation]}]" }.join(",\n"),
      'slope_chart_data' =>
        inclines.map.with_index {
          |incline, idx| "[#{idx},#{incline[:slope_percentage]}]" }.join(",\n")
    }

    File.open(filename, 'w') do |file|
      file.print Liquid::Template.parse(
        File.read(
          File.join(File.dirname(__FILE__),
            '../../templates/inspection_report.html'))).
              render(template_parameters)
    end

  end
end
