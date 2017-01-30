require 'httpclient'

module Imperium
  class HTTPClient
    class << self
      def http_driver
        @http_driver ||= ::HTTPClient.new
      end
    end

    attr_reader :config

    def initialize(config)
      @config = config
    end

    def delete(path)
      url = config.url.join(path)
      http_driver.delete(url)
    end

    def get(path, query: {})
      url = config.url.join(path)
      url.query_values = query
      http_driver.get(url, header: build_request_headers)
    end

    def put(path, value)
      url = config.url.join(path)
      http_driver.put(url, body: value)
    end

    private

    def build_request_headers
      if config.token?
        {'X-Consul-Token' => config.token}
      else
        {}
      end
    end

    def http_driver
      self.class.http_driver
    end
  end
end
