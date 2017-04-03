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
      wrapping_exceptions do
        url = config.url.join(path)
        @driver.delete(url)
      end
    end

    def get(path, query: {})
      wrapping_exceptions do
        url = config.url.join(path)
        url.query_values = query
        @driver.get(url, header: build_request_headers)
      end
    end

    def put(path, value)
      wrapping_exceptions do
        url = config.url.join(path)
        @driver.put(url, body: value)
      end
    end

    private

    def build_request_headers
      if config.token?
        {'X-Consul-Token' => config.token}
      else
        {}
      end
    end

    # We're doing this wrap and re-raise dance to give a more consistent set of
    # exceptions that can come from us.
    def wrapping_exceptions
      yield
    rescue SocketError => ex
      if ex.message.start_with?("getaddrinfo: Name or service not known")
        raise Imperium::UnableToConnectError, ex.message
      else
        raise
      end
    rescue ::HTTPClient::ConnectTimeoutError => ex
      raise Imperium::ConnectTimeout, ex.message
    rescue ::HTTPClient::SendTimeoutError => ex
      raise Imperium::SendTimeout, ex.message
    rescue ::HTTPClient::ReceiveTimeoutError => ex
      raise Imperium::ReceiveTimeout, ex.message
    end
  end
end
