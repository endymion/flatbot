require "flatbot/version"
require 'haversine'

require 'flatbot/cli'
require 'flatbot/computation'
require 'flatbot/coordinate'
require 'flatbot/inspect'

require 'ruby-progressbar'

require 'envyable'
Envyable.load('config/env.yml')

class Flatbot
  def initialize(options, logger=nil)
    @options = options
  end
end
