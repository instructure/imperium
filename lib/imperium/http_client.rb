require 'httpclient' # From HTTPClient
require 'json'

module Imperium
  class HTTPClient
    class << self
      private
      def http_driver
        @http_driver ||= ::HTTPClient.new
      end
    end

    attr_reader :config

    def initialize(config)
      @config = config
    end

    def delete(path)
      url = config.url.dup
      url.path = path
      http_driver.delete(url.to_s)
    end

    def put(path, value)
      url = config.url.dup
      url.path = path
      http_driver.put(url.to_s, body: value)
    end

    private

    define_method :http_driver, &method(:http_driver)
  end
end
