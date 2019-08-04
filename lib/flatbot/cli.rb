require 'thor'
require 'awesome_print'
require 'colorize'
require 'polylines'

module Flatbot

  class CLI < Thor

    desc "slopes [start] [finish]", "Compute slope percentages along a route."
    long_desc <<-LONGDESC
      Compute slope percentages along a route.

      Flatbot will interpolate points between each two points along the
      directions between the start and finish provided by Google Maps.  At each
      interpolated point, it will measure the elevation and calculate the
      slope percentage from the previous point.

      Provide start and finish as lat / long strings.  Example:

      $ flatbot slopes "46.259181, -96.037663" "45.562839, -94.235428"

      The default number of interpolated points is three, meaning that it will
      add one interpolated point between each two points along the path.  You
      can control the number of interpolated points with the "subdivisions"
      option:

      $ flatbot slopes "46.259181, -96.037663" "45.562839, -94.235428" --subdivisions 5
    LONGDESC
    option :subdivisions
    def slopes(start, from)

      Flatbot::Slopes.new.compute(start, from, options[:subdivisions] || 3)

    end

  end

end
