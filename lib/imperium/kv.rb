module Imperium
  class KV < Client
    self.path_prefix = 'v1/kv'.freeze

    def self.get(key, *options)
      default_client.get(key, *options)
    end

    def delete(key, *_)
      @http_client.delete(prefix_path(key))
    end

    def get(key, *options)
      response = @http_client.get(prefix_path(key))
      parsed_body = JSON.parse(response.body)
      Base64.decode64(parsed_body.first['Value'])
    end

    def put(key, value, *_)
      @http_client.put(prefix_path(key), value)
    end
  end
end
