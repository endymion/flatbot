require 'thor'
require 'polylines'

class Flatbot

  class CLI < Thor

    desc "inspect [start] [finish]", "Compute slope percentages along a route."
    long_desc <<-LONGDESC
      Inspect a route, seeking joy.

      Flatbot will interpolate points between each two points along the directions between the start and finish provided by Google Maps.  At each interpolated point, it will measure the elevation and calculate the slope percentage from the previous point.

      Any slope that exceeds the threshold will generate a warning.  The default threshold is 30, representing a slope percentage of 30%.

      Provide start and finish as lat / long strings.  Example:

      $ flatbot slopes "46.259181, -96.037663" "45.562839, -94.235428"

      The default number of interpolated points is one, meaning that it will add one interpolated point between each two points along the path.  You can control the number of interpolated points with the "interpolations" option:

      $ flatbot slopes "46.259181, -96.037663" "45.562839, -94.235428" --interpolations 3
    LONGDESC
    option :threshold, desc: "The maximum slope percentage to allow before rejecting this course.", default: 30, aliases: '-t'
    option :output, desc: "Output CSV data to this file.", aliases: '-o'
    option :interpolations, desc: "The number of interpolated points to add between each two points along the path.", default: 1
    option :verbose, desc: 'Show all of the details.', aliases: '-v'
    option :report, desc: 'Location of the report.', aliases: '-r', default: 'Flatbot report.html'
    option :name, desc: 'Name of this route.  Example: "Maryhill Loop Road"', aliases: '-n'
    def inspect(start, from)

      Flatbot.new(options).inspect(start, from)

    end

  end

end
