require_relative 'client'

module Imperium
  # A client for the Catalog API.
  class Catalog < Client
    self.path_prefix = 'v1/catalog'.freeze

    # List services in the global catalog
    #
    # @return [Response]
    def list_services
      response = @http_client.get(prefix_path('services'))
      Response.new(response)
    end

    # List the known nodes for the given service in the global catalog
    #
    # Returns a {Response} object that coerces the returned data into {Service}
    # objects
    #
    # @param [String] :service
    # @return [Array<Service>]
    def list_nodes_for_service(service)
      response = @http_client.get(prefix_path("service/#{service}"))
      Response.new(response, response_object_class: Service)
    end
  end
end
require_relative 'catalog/service'
