module Imperium
  # A client for the Events API.
  class Events < Client
    self.path_prefix = 'v1/event'.freeze

    # {#fire fire} an event using the {.default_client}
    # @see #fire
    def self.fire(name, payload = nil, dc: nil, node: nil, service: nil, tag: nil)
      default_client.fire(name, payload, dc: dc, node: node, service: service, tag: tag)
    end

    # Fire the event
    #
    # @example Firing an event with a payload
    #   response = Imperium::Events.fire('foo/bar', 'mypayload') # => EventResponse...
    #
    # @param [String] name The name of the event
    # @param [String] payload Additional data to send as payload of the event
    # @param [String] dc Specify the datacenter to use for the request
    # @param [String] node Specifies a regular expression to filter by node name
    # @param [String] service Specifies a regular expression to filter by service name
    # @param [String] tag Specifies a regular expression to filter by tag
    # @return [EventResponse]
    def fire(name, payload = nil, dc: nil, node: nil, service: nil, tag: nil)
      query = {}
      query[:dc] = dc if dc
      query[:node] = node if node
      query[:service] = service if service
      query[:tag] = tag if tag
      response = @http_client.put(prefix_path("fire/#{name}"),
                                  payload, query: query)
      EventFireResponse.new(response)
    end
  end
end
