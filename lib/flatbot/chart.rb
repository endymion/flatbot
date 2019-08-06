class Flatbot

  def elevation_chart_data(locations)
    total_distance  = 0
    chart_data = []
    (locations.length - 1).times do |i|
      from_location = locations[i]
      to_location = locations[i+1]

      run = distances([from_location, to_location])[0]
      total_distance += run
      chart_data << "[#{total_distance / 1000},#{to_location[:elevation]}]"
    end
    chart_data.join(",\n")
  end

  def slope_chart_data(locations)
    total_distance  = 0
    chart_data = []
    (locations.length - 1).times do |i|
      from_location = locations[i]
      to_location = locations[i+1]

      run = distances([from_location, to_location])[0]
      total_distance += run
      chart_data << "[#{total_distance / 1000},#{to_location[:slope_percentage]}]"
    end
    chart_data.join(",\n")
  end

end
