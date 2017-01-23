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
      # build url
      #   build path
      #   build query from options && config
      #
      # make request
      # parse request
      # manipulate into hash or String
    end

    def put(key, value, *_)
      @http_client.put(prefix_path(key), value)
    end
  end
end
