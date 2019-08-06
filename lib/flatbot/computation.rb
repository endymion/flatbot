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

      slope_percentage = rise / run * 100
      inclines << to_location.merge(slope_percentage: slope_percentage)

      if @options['verbose']
        @progressbar.log "computed a slope."
        @progressbar.log "from: "
        @progressbar.log from_location.ai(indent: -2, ruby19_syntax: true)
        @progressbar.log "to: "
        @progressbar.log to_location.ai(indent: -2, ruby19_syntax: true)
        @progressbar.log "rise: " + "#{rise.round(2)}m".blue
        @progressbar.log "run: " + "#{run.round(2)}m".blue
        @progressbar.log "slope: " + "#{slope_percentage.round(2)}%\n".blue
      end

      if @options['threshold'] && @options['threshold'].to_f <= slope_percentage
        @progressbar.stop
        @progressbar.log "REJECTED".red
        @progressbar.log "Slope percentage " + slope_percentage.round(4).to_s.red +
          " exceeds threshold #{@options['threshold']}"
        @progressbar.log "rise: " + "#{rise.round(2)}m".red
        @progressbar.log "run: " + "#{run.round(2)}m".red
        @progressbar.log "coordinates:"
        @progressbar.log from_location.ai(indent: -2, ruby19_syntax: true)
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

  # Computes the Pain metric for a series of locations, by calculating the
  # area under the slope curve when the slope is positive.
  #
  # @param [Array] locations An array of (n) locations along a path.
  # @return [Numeric] A number that represents the Pain metric.
  def pain(locations)
    total_run = 0
    total_pain = 0
    # For each pair of locations,
    (locations.length - 1).times do |i|
      from_location = locations[i]
      to_location = locations[i+1]

      rise = to_location[:elevation] - from_location[:elevation]
      run = distances([from_location, to_location])[0]
      slope_percentage = rise / run * 100
      total_run += run

      area = slope_percentage * run
      total_pain += area if area > 0
    end

    total_pain / total_run
  end

  # Computes the Joy metric for a series of locations, by calculating the
  # area under the slope curve when the slope is negative.
  #
  # @param [Array] locations An array of (n) locations along a path.
  # @return [Numeric] A number that represents the Joy metric.
  def joy(locations)
    total_run = 0
    total_joy = 0
    # For each pair of locations,
    (locations.length - 1).times do |i|
      from_location = locations[i]
      to_location = locations[i+1]

      rise = to_location[:elevation] - from_location[:elevation]
      run = distances([from_location, to_location])[0]
      slope_percentage = rise / run * 100
      total_run += run

      area = slope_percentage * run
      total_joy -= area if area < 0
    end

    total_joy / total_run
  end

end
