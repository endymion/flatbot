# Flatbot

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/flatbot`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'flatbot'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install flatbot

## Usage

### Running with RVM

You can probably run this in your local environment without using a VM or a container if you're using a Unix machine.  You will probably need to install the recent Ruby version that Flatbot uses with [RVM](https://rvm.io/).

#### Install RVM

https://rvm.io/rvm/install

#### Use RVM to select the right Ruby version

From the project directory, tell it to use the version in the `.rvmrc`

    rvm use .

You might need to install that version.  RVM will tell you how.

### Running with Docker

You don't need to do this.  But you might have problems with RVM or something.

I used a Docker container to test the CLI interface that the Ruby gem installs.

#### Building the container

    docker build -t flatbot .

#### Starting the container and getting a Bash shell

    docker run -it --mount src="$(pwd)",target=/flatbot,type=bind flatbot

#### Bundle gems within the container

    cd /flatbot
    bundle install

#### Build and install the gem locally inside of the container

    rake install

#### Run the CLI

    flatbot

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/flatbot.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
