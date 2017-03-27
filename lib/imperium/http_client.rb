require 'httpclient'

module Imperium
  class HTTPClient
    attr_reader :config

    def initialize(config)
      @config = config
      @driver = ::HTTPClient.new
      @driver.connect_timeout = @config.connect_timeout
      @driver.send_timeout = @config.send_timeout
      @driver.receive_timeout = @config.receive_timeout
    end

    def delete(path)
      url = config.url.join(path)
      @driver.delete(url)
    end

    def get(path, query: {})
      url = config.url.join(path)
      url.query_values = query
      @driver.get(url, header: build_request_headers)
    end

    def put(path, value)
      url = config.url.join(path)
      @driver.put(url, body: value)
    end

    private

    def build_request_headers
      if config.token?
        {'X-Consul-Token' => config.token}
      else
        {}
      end
    end
  end
end
