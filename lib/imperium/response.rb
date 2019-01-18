require 'delegate'

module Imperium
  # A Response is a decorator around the
  # {http://www.rubydoc.info/gems/httpclient/HTTP/Message HTTP::Message} object
  # returned when a request is made.
  #
  # It exposes, through a convenient API, headers common to all interactions
  # with the Consul HTTP API
  class Response < SimpleDelegator
    include Enumerable

    class << self
      attr_accessor :default_response_object_class
    end

    # Construct a new response
    #
    # @param response [HTTP::Message] The response as returned from the http client
    # @param response_object_class [APIObject] The class to coerce values into,
    #   if left the default (:none) no coersion will be attempted.
    def initialize(response, response_object_class: :none)
      super(response)
      @klass = if response_object_class == :none
                 self.class.default_response_object_class
               else
                 response_object_class
               end
    end

    # Indicates if the contacted server has a known leader.
    #
    # @return [TrueClass] When the response indicates there is a known leader
    # @return [FalseClass] When the response indicates there is not a known leader
    # @return [NilClass] When the X-Consul-KnownLeader header is not present.
    def known_leader?
      return unless headers.key?('X-Consul-KnownLeader')
      headers['X-Consul-KnownLeader'] == 'true'
    end

    # The time in milliseconds since the contacted server has been in contact
    # with the leader.
    #
    # @return [NilClass] When the X-Consul-LastContact header is not present.
    # @return [Integer]
    def last_contact
      return unless headers.key?('X-Consul-LastContact')
      Integer(headers['X-Consul-LastContact'])
    end

    # The index returned from a request via the X-Consul-Index header.
    #
    # @return [NilClass] When the X-Consul-Index header is not present.
    # @return [Integer]
    def index
      return nil unless headers.key?('X-Consul-Index')
      Integer(headers['X-Consul-Index'])
    rescue ArgumentError
      return nil
    end

    ##
    # A convenience method for checking if the response had a 404 status code.
    def not_found?
      status == 404
    end

    # Indicate status of translate_wan_addrs setting on the server.
    #
    # @return [TrueClass] When X-Consul-Translate-Addresses is set
    # @return [FalseClass] When X-Consul-Translate-Addresses is unset
    def translate_addresses?
      headers.key?('X-Consul-Translate-Addresses')
    end

    # Iterate over the values contained in the structure returned from {#coerced_body}
    def each(&block)
      coerced_body.each(&block)
    end

    # Parse the response JSON and initialize objects using the class passed to the constructor.
    #
    # @return [Array<Hash, APIObject>, Hash<String => APIObject>]
    def coerced_body
      return parsed_body if @klass == :none || @klass.nil?
      @coerced_body ||= if parsed_body.is_a?(Array)
                          parsed_body.map { |attrs| @klass.new(attrs) }
                        else
                          parsed_body.each_with_object({}) { |(k, attrs), h|
                            h[k] = @klass.new(attrs)
                          }
                        end
    end

    private

    def parsed_body
      @parsed_body ||= JSON.parse(content)
    end
  end
end
