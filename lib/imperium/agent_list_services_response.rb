require_relative 'response'
require_relative 'service'

module Imperium
  # AgentListServiceResponse is a wrapper for the raw HTTP::Message response
  #   from the API
  #
  # @note This class doesn't really make sense to be instantiated outside of
  #   {Agent#list_services}
  #
  # We've included Enumerable and implemented #each so it can be treated as an
  # array of {Service} objects.
  class AgentListServicesResponse < Response
    self.default_response_object_class = Service

    def each(&block)
      services.each(&block)
    end

    # Build an array of {Service} objects from the response
    #
    # @return [Array<Service>] This array will be empty when the response is not
    #   a success
    def services
      @services ||= services_hash.values
    end

    # Build a hash of {Service} object from the response
    #
    # The keys are the service's id from the API response.
    # @return [Hash<String => Service>]
    def services_hash
      @services_hash ||= (ok? ? coerced_body : {})
    end
  end
end
