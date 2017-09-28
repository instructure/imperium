require 'imperium/error'

require 'imperium/agent'
require 'imperium/agent_list_checks_response'
require 'imperium/agent_list_services_response'
require 'imperium/client'
require 'imperium/configuration'
require 'imperium/event_fire_response'
require 'imperium/events'
require 'imperium/http_client'
require 'imperium/kv'
require 'imperium/kv_pair'
require 'imperium/kv_get_response'
require 'imperium/kv_put_response'
require 'imperium/response'
require 'imperium/service'
require 'imperium/service_check'
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
