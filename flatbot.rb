require 'envyable'
Envyable.load('config/env.yml')

require 'google_maps_service'
gmaps = GoogleMapsService::Client.new(
  key: ENV['GOOGLE_MAPS_API_KEY'])

require 'haversine'

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

# Computes the percentage of incline, as a ratio of height, between each two
# locations in the provided array of locations.
#
# @param [Array] locations An array of (n) locations along a path.
# @return [Array] An array of (n-1) slope percentage values for each pair of
#   locations along that path.  The value [0] in the output is the incline from
#   locations [0] and [1] in the input.  The value [n-1] in the output is the
#   incline from locations [n-1] and [n] in the input.  The slope percentage
#   is calculated by dividing the "rise" (difference in elevation) by the "run"
#   (distance).
def inclines(locations)
  # An empty array to hold computed values so that we can return them later.
  inclines = []

  # For each pair of locations,
  (locations.length - 1).times do |i|
    from_location = locations[i]
    to_location = locations[i+1]
    rise = to_location[:elevation] - from_location[:elevation]
    run = distances([from_location, to_location])[0]
    slope_percentage = rise / run
    inclines << slope_percentage
  end
  
  # Return the computed slope percentage array.
  inclines
end

# Computes the distance between in meters each two locations in the
# provided array of locations using the Haversine formula.
#
# @param [Array] locations An array of (n) locations along a path.
# @return [Array] An array of (n-1) distance values for each pair of locations
#   along that path.  The value [0] in the output is the distance between
#   locations [0] and [1] in the input.  The value [n-1] in the output is the
#   distnace between locations [n-1] and [n] in the input.  The distance is
#   is calculated using the Haversine formula.
def distances(locations)
  # An empty array to hold computed values so that we can return them later.
  distances = []

  # For each pair of locations,
  (locations.length - 1).times do |i|
    from_location = locations[i]
    to_location = locations[i+1]
    distances <<
      Haversine.distance(
        [from_location[:location][:lat], from_location[:location][:lng]],
        [to_location[:location][:lat], to_location[:location][:lng]]   
      ).to_meters
  end
  
  # Return the distance array.
  distances
end

locations_with_elevation = gmaps.elevation_along_path(locations, 2)

distances = distances(locations_with_elevation)
puts "Distances: #{distances.inspect}"

inclines = inclines(locations_with_elevation)
puts "Inclines: #{inclines.inspect}"