require './lib/flatbot'
require 'awesome_print'
require 'polylines'

require 'envyable'
Envyable.load('config/env.yml')

require 'google_maps_service'
gmaps = GoogleMapsService::Client.new(
  key: ENV['GOOGLE_MAPS_API_KEY'])

locations = [
  {
    latitude: 46.259181,
    longitude: -96.037663
  },
  {
    latitude: 45.562839,
    longitude: -94.235428
  }
]

routes = gmaps.directions(
  locations[0],
  locations[1],
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
        gmaps.elevation_along_path([from_location, to_location], 3).flatten

      interpolated_locations_with_elevation_this_step.map do |location|
        puts location[:elevation]
      end

      # puts inclines(interpolated_locations_with_elevation_this_step).join("\n")
    end

  end
end




