require 'addressable/uri'
require 'forwardable'

module Imperium
  class Configuration
    extend Forwardable

    attr_reader :url
    attr_accessor :token

    def initialize(url: 'http://localhost:8500', token: nil)
      @url = Addressable::URI.parse(url)
      @token = token
    end

    def_delegators :@url, :host, :host=, :port, :port=

    def ssl?
      @url.scheme == 'https'
    end

    def ssl=(value)
      @url.scheme = (!!value ? 'https' : 'http')
    end

    def url=(value)
      @url = (value.nil? ? nil : Addressable::URI.parse(value))
    end
  end
end
