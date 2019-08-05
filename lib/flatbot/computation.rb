class Flatbot

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
      inclines << to_location.merge(slope_percentage: slope_percentage)

      if @options['verbose']
        @logger.log "computed a slope."
        @logger.log "from: " + from_location.ai(indent: -2, ruby19_syntax: true)
        @logger.log "to: " + to_location.ai(indent: -2, ruby19_syntax: true)
        @logger.log "rise: " + "#{rise.round(2)}m".blue
        @logger.log "run: " + "#{run.round(2)}m".blue
        @logger.log "slope: " + "#{slope_percentage.round(2)}%\n".blue
      end
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

end
