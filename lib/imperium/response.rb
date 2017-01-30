require 'delegate'

module Imperium
  # A Response is a decorator around the
  # {http://www.rubydoc.info/gems/httpclient/HTTP/Message HTTP::Message} object
  # returned when a request is made.
  #
  # It exposes, through a convenient API, headers common to all interactions
  # with the Consul HTTP API
  class Response < SimpleDelegator
    # Indicates if the contacted server has a known leader.
    #
    # @return [TrueClass] When the response indicates there is a known leader
    # @return [FalseClass] When the response indicates there is not a known leader
    # @return [NilClass] When the X-Consul-KnownLeader header is not present.
    def known_leader?
      return unless headers.key?('X-Consul-KnownLeader')
      headers['X-Consul-KnownLeader'] == 'true'
    end

    # The time in miliseconds since the contacted server has been in contact
    # with the leader.
    #
    # @return [NilClass] When the X-Consul-LastContact header is not present.
    # @return [Integer]
    def last_contact
      return unless headers.key?('X-Consul-LastContact')
      Integer(headers['X-Consul-LastContact'])
    end

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

    private

    def parsed_body
      JSON.parse(content)
    end
  end
end
