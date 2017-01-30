# Imperium

Imperium is a Latin word which roughly translates to 'power to command'. It was
often applied to official, and unofficial, positions of power. In this case,
specifically the office of Consul.

Imperium is a Consul client for Ruby applications, it aims to be as ergonomic
as possible for users while giving the flexibility required for complex
applications. At first only the KV store will be supported but additional
functionality is expected to be added as needed (or as pull requests are
submitted).

## Motivation.
As Instructure's use of Consul has grown so have our wants and needs in a client
library have grown. The goal of this gem is to provide a lightweight, thread
safe interface to the full power of Consul's API while not forcing the consumer
to use all of it where unnecessary. For now we're focusing on the KV store since
most of our use revolves around it.

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
# The following configuration values are used for the default client for each
# service. This isn't the only way to get a client set up but will fill the
# needs of most applications.
Imperium.configure do |config|
  # Connection values can be specified separately
  config.host = 'consul.example.com'
  config.port = 8585 
  config.ssl = false

  # Or, as a url (this is equivilant to the example above).
  config.url = 'http://consul.example.com:8585'

  confg.token = 'super-sekret-value'
end

# If you want a client that uses some other configuration values without altering
# the default ones you can directly instantiate a Configuration object:

config = Imperium::Configuration.new(url: 'https://other-consul.example.com', token: 'foobar')
# This client will contact other-consul.example.com rather than the one configured above.
kv_client = Imperium::KV.new(config) 
```

GET values from the KV store:
```
# Get a single value
response = Imperium::KV.get('config/single-value', :stale) 
response.values # => 'qux'

# Get a set of nested values
response = Imperium::KV.get('config/complex-value', :recurse) 
response.values # => {first: 'value', second: 'value'}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`bin/rspec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/instructure/imperium.
