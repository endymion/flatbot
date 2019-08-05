
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "flatbot/version"

Gem::Specification.new do |spec|
  spec.name          = "flatbot"
  spec.version       = Flatbot::VERSION
  spec.authors       = ["Ryan Porter"]
  spec.email         = ["rap@endymion.com"]

  spec.summary       = %q{Flatbot is on a quest to find the Holy Grail of mellow downhill longboarding slopes.}
  spec.description   = %q{A Ruby CLI utility for using Google Maps to compute slope angles over a path, and other things.}
  spec.homepage      = "https://github.com/endymion/flatbot"
  spec.license       = "MIT"

  spec.files         = Dir["{lib,exe}/**/*", "LICENSE", "README.md"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.10.4"
  spec.add_dependency "colorize", "~> 0.8.1"
  spec.add_dependency "envyable", "~> 1.2.0"
  spec.add_dependency "awesome_print", "~> 1.8.0"
  spec.add_dependency "google_maps_service", "~> 0.4.2"
  spec.add_dependency "haversine", "~> 0.3.2"
  spec.add_dependency "polylines", "~> 0.3.0"
  spec.add_dependency "thor", "~> 0.20.3"
  spec.add_dependency "ruby-progressbar", "~> 1.10.1"
end
