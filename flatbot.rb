require 'envyable'
Envyable.load('config/env.yml')

require 'google_maps_service'
gmaps = GoogleMapsService::Client.new(key: ENV['GOOGLE_MAPS_API_KEY'])

locations = [
  {
    latitude: 40.714224,
    longitude: -73.961452
  },
  {
    latitude: -34.397,
    longitude: 150.644
  }
]

puts gmaps.elevation_along_path(locations, 5).inspect
