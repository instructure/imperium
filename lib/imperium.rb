require 'imperium/configuration'
require 'imperium/client'
require 'imperium/kv'
require 'imperium/http_client'
require 'imperium/version'

module Imperium
  def self.configure
    yield configuration
  ensure
    Client.reset_default_clients
  end

  def self.configuration
    @configuration ||= Configuration.new
  end
end
