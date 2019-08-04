require 'google_maps_service'

module Flatbot
  class Slopes

    def compute(start, finish, subdivisions=3)

      gmaps = GoogleMapsService::Client.new(
        key: ENV['GOOGLE_MAPS_API_KEY'])

      routes = gmaps.directions(
        Flatbot::Coordinate.from_string(start),
        Flatbot::Coordinate.from_string(finish),
        mode: 'bicycling',
        avoid: ['highways', 'tolls', 'ferries'],
        units: 'metric',
        alternatives: false)

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
                subdivisions
              ).flatten

            interpolated_locations_with_elevation_this_step.map do |location|
              puts "location: #{location.inspect}"
            end

            puts "slope percentages:\n" +
              Flatbot::Computation.new.
                inclines(interpolated_locations_with_elevation_this_step).
                join("\n") + "\n\n"

          end
        end
      end
    end
  end
end
