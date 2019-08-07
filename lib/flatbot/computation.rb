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

      if @options['max_slope'] && @options['max_slope'].to_f <= slope_percentage
        @progressbar.stop
        @progressbar.log "REJECTED".red
        @progressbar.log "Slope percentage " + slope_percentage.round(4).to_s.red +
          " exceeds max_slope #{@options['max_slope']}"
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

    total_pain
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

    total_joy
  end

  # Computes an array of climbs across the path.  Each climb must be at least
  # as long as the minimum slope distance to count.
  #
  # @param [Array] locations An array of (n) locations along a path.
  # @return [Array] An array of climbs, where each climb is a hash containing
  # both an elevation change and a distance change.
  def climbs(locations)
    # The array of climbs that this method will return.
    climbs = []

    # The locations in the current climb.
    this_climb = []

    # For each pair of locations,
    (locations.length - 1).times do |i|
      from_location = locations[i]
      to_location = locations[i+1]

      rise = to_location[:elevation] - from_location[:elevation]
      run = distances([from_location, to_location])[0]
      slope_percentage = rise / run * 100
      area = slope_percentage * run
      current_location = to_location.merge(
        rise: rise,
        run: run,
        slope_percentage: slope_percentage,
        area: area
      )

      # If the area changes from negative to positve or positive to negative,
      if (
        ((this_climb.last && (this_climb.last[:area] > 0)) && current_location[:area] < 0) ||
        ((this_climb.last && (this_climb.last[:area] < 0)) && current_location[:area] > 0)
      ) ||
      # or the area goes to zero,
      area.zero?

        # then close out this climb.
        climbs << this_climb
        this_climb = []
      end

      # If this is the start of a new climb,
      if (this_climb.empty? && !area.zero?) ||
        # or if the slope area is the same as it was previously,
        (
          !this_climb.length.zero? && (
            (this_climb.last[:area] > 0 && current_location[:area] > 0) ||
            (this_climb.last[:area] < 0 && current_location[:area] < 0)
          )
        )
        # then add this location to the current climb.
        this_climb << current_location
      end

    end

    climbs << this_climb unless this_climb.empty?

    # Each climb is now represented by an array of segments.
    # Each segment contains a slope area and distance.

    # Next we must transform each array of segments into one hash that
    # represents one climb, with a rise and a run.
    climbs.reject!{|climb| climb.empty?}
    unless climbs.empty?
      climbs.map! do |climb|
        rise = climb.sum{|segment| segment[:rise]}
        run = climb.sum{|segment| segment[:run]}
        slope_percentage = (rise / run * 100).round(2)
        area = climb.sum{|segment| segment[:area] }
        pain = (slope_percentage * run).round(2)

        # Compute the slope score for this segment.
        score_emoji =
          case slope_percentage
          when 5...Float::INFINITY
            '🤬'
          when 4...5
            '🥵'
          when 3...4
            '😡'
          when 2...3
            '😠'
          when 1...2
            '🙁'
          when 0.5...1
            '😐'
          when -0.5...0.5
            '😎'
          when -1...-0.5
            '🙂'
          when -1.5...-1
            '😀'
          when -2...-1.5
            '😃'
          when -2.5...-2
            '😄'
          when -3...-2.5
            '😁'
          when -3.5...-3
            '🙃'
          when -4...-3.5
            '😑'
          when -4.5...-4
            '😬'
          when -5...-4.5
            '😯'
          when -5.5...-5
            '😦'
          when -6...-5.5
            '😧'
          when -6.5...-6
            '😮'
          when -8.5...-6
            '😲'
          when -Float::INFINITY...-8.5
            '😵'
          end

        score_color =
          case slope_percentage
          when 4...Float::INFINITY
            '#f5c6cb'
          when 2...4
            '#ffeeba'
          when -4...-2
            '#ffeeba'
          when -Float::INFINITY...-4
            '#f5c6cb'
          else
            '#fff'
          end

        {
          'rise' => rise.round(2),
          'run' => run.round(2),
          'slope_percentage' => slope_percentage,
          'area' => area.round(2),
          'pain' => pain,
          'joy' => -pain,
          'score_emoji' => score_emoji,
          'score_color' => score_color,
          'elevation_chart_data' => elevation_chart_data(climb),
          'slope_chart_data' => slope_chart_data(climb)
        }
      end
    end

    # Exclude any climb where the run is less than the minimum climb run.
    climbs.select! do |climb|
      climb['run'] >= @options['min_run'].to_f &&
      (climb['slope_percentage'] >= @options['min_slope_percentage'].to_f ||
       climb['slope_percentage'] <= -@options['min_slope_percentage'].to_f)
    end

    climbs
  end

end
