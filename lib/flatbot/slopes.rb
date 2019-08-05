require 'csv'
require 'awesome_print'
require 'google_maps_service'

class Flatbot

  def slopes(start, finish)

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
          Polylines::Decoder.decode_polyline(step[:polyline][:points]).length
      end
    end

    inclines = []
    routes[0][:legs].each do |leg|
      leg[:steps].each do |step|

        locations =
          Polylines::Decoder.decode_polyline(step[:polyline][:points])

        (locations.length - 1).times do |i|
          from_location = locations[i]
          to_location = locations[i+1]

          interpolated_locations_with_elevation_this_step =
            gmaps.elevation_along_path(
              [from_location, to_location],
              # Google Maps wants the total nubmer of
              # interpolated points, including the first
              # and last.
              @options['interpolations'] + 2
            ).flatten

          inclines <<
            inclines(interpolated_locations_with_elevation_this_step)
          break
          @progressbar.increment

        end
      end
    end

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

  end
end
