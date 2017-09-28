require 'imperium/client'

module Imperium
  # A client for the Agent API.
  class Agent < Client
    self.path_prefix = 'v1/agent'.freeze

    # Deregister a service with the agent.
    #
    # @see https://www.consul.io/api/agent/service.html#deregister-service Consul's Documentation
    #
    # @param service_or_id [Service, String] The object or id representing the
    #   service to be removed from the services registry.
    def deregister_service(service_or_id)
      id = (service_or_id.is_a?(Service) ? service_or_id.id : service_or_id)
      Response.new(@http_client.put(prefix_path("service/deregister/#{id}"), ''))
    end

    # Retreive a list of all checks registered to the local agent.
    #
    # @see https://www.consul.io/api/agent/check.html#list-checks Consul's Documentation
    # @return [AgentListChecksResponse]
    def list_checks
      response = @http_client.get(prefix_path('checks'))
      AgentListChecksResponse.new(response)
    end

    # Retreive a list of all services registered to the local agent.
    #
    # @see https://www.consul.io/api/agent/service.html#list-services Consul's Documentation
    # @return [AgentListServicesResponse]
    def list_services
      response = @http_client.get(prefix_path('services'))
      AgentListServicesResponse.new(response)
    end

    # Register a new service with the agent.
    #
    # @see https://www.consul.io/api/agent/service.html#register-service Consul's Documentation
    #
    # @param service [Serivce] A {Service} object containing the data to use
    #   for registration
    def register_service(service)
      Response.new(@http_client.put(prefix_path('service/register'), service.registration_data))
    end
  end
end

