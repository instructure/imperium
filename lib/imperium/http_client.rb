require 'httpclient'

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
      http_driver.delete(url)
    end

    def get(path)
      url = config.url.dup
      url.path = path
      http_driver.get(url)
    end

    def put(path, value)
      url = config.url.dup
      url.path = path
      http_driver.put(url, body: value)
    end

    private

    define_method :http_driver, &method(:http_driver)
  end
end
