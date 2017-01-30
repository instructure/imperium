require 'addressable/uri'
require 'forwardable'

module Imperium
  # The Configuration class represents the values necessary for making contact
  # with a Consul agent.
  #
  # @!attribute [rw] token
  #   @return [String] The token to be used when making requests to the Consul
  #   APIs. Defaults to `nil`
  # @!attribute [rw] url
  #   @return [Addressable::URI] The base URL, including port, for contacting
  #   the Consul agent. Defaults to `http://localhost:8500`
  class Configuration
    extend Forwardable

    attr_reader :url
    attr_accessor :token

    def initialize(url: 'http://localhost:8500', token: nil)
      @url = Addressable::URI.parse(url)
      @token = token
    end

    def_delegators :@url, :host, :host=, :port, :port=

    # Check if the specified URL is using SSL/TLS
    # @return [Boolean]
    def ssl?
      @url.scheme == 'https'
    end

    # Configure the clients to use SSL/TLS (or not).
    #
    # @param value [Boolean]
    # @raise [NoMethodError] When the URL has previously been set to nil.
    def ssl=(value)
      @url.scheme = (!!value ? 'https' : 'http')
    end

    # Check for the presence of a token
    # @return [Boolean]
    def token?
      @token && !@token.empty?
    end

    # Set the URL
    #
    # This method will append a trailing slash to the supplied URL if not
    # included. We're doing this because merging a path onto a URL missing the
    # trailing slash will remove any extant path components.
    #
    # @param value [String, Addressable::URI, URI::GenericURI] The new value to use.
    def url=(value)
      if value.nil?
        @url = nil
      else
        @url = Addressable::URI.parse(value)
        @url.path << '/' unless @url.path.end_with?('/')
      end
    end
  end
end
