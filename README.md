# Imperium

Imperium is a Latin word which roughly translates to 'power to command'. It was
often applied to official, and unofficial, positions of power. In this case,
specifically the office of Consul.

Imperium is a Consul client for Ruby applications, it aims to be as ergonomic
as possible for users while giving the flexibility required for complex
applications. At first only the KV store will be supported but additional
functionality is expected to be added as needed (or as pull requests are
submitted).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'imperium'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install imperium

## Usage

Configure:

```
Imperium.configure do |config|
  # set values here
end
```

Access KV store:
```
# Get a single value
Imperium::KV.get('config/single-value', :stale) #=> 'qux'

# Get a set of nested values
Imperium::KV.get('config/complex-value', :recurse) # => {first: 'value', second: 'value'}

# Requesting a set of nested values without the :recurse option
Imperium::KV.get('config/complex-value', :recurse) # => nil
# or, depending on config
Imperium::KV.get('config/complex-value', :recurse) # => raise Imperium::KV::NotFound
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/imperium.

