require "flatbot/version"
require 'haversine'

require 'flatbot/cli'
require 'flatbot/computation'
require 'flatbot/coordinate'
require 'flatbot/slopes'

require 'ruby-progressbar'

require 'envyable'
Envyable.load('config/env.yml')

class Flatbot
  def initialize(options, logger=nil)
    @options = options
    @progressbar = ProgressBar.create(
      total: 0,
      autofinish: false,
      format: "Flatbot has inspected: %c of %C path segments in %a %e %P%"
    )
  end
end
