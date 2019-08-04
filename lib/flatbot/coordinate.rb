module Flatbot

  class Coordinate

    # Translates a string into a hash with :latitude and :longitude values.
    #
    # @param [String] A string with latitute and longitude, separated in some way.
    # @return [Hash] A hash with two separate values, :latitude, and :longitude, each repesented as a string.
    def self.from_string(string)
      parts = string.split(/[^\d\.\-]+/)
      return {latitude: parts[0], longitude: parts[1]}
    end

  end
end
