module Imperium
  # A client for the KV API.
  class KV < Client
    self.path_prefix = 'v1/kv'.freeze

    # {#get GET} a key using the {.default_client}
    # @see #get
    def self.get(key, *options)
      default_client.get(key, *options)
    end

    # Delete the specified key
    # @note This is really a stub of this method, it will delete the key but
    #   you'll get back a raw
    #   {http://www.rubydoc.info/gems/httpclient/HTTP/Message HTTP::Message}
    #   object. If you're really serious about using this we'll probably want
    #   to build a wrapper around the response with some logic to simplify
    #   interpreting the response.
    #
    # @param key [String] The key to be deleted
    # @param options [Array] Un-used, only here to prevent changing the method
    #   signature when we actually implement more advanced functionality.
    # @return [HTTP::Message]
    def delete(key, *options)
      @http_client.delete(prefix_path(key))
    end

    GET_ALLOWED_OPTIONS = %i{consistent stale recurse keys separator raw}.freeze
    private_constant :GET_ALLOWED_OPTIONS
    # Get the specified key/prefix using the supplied options.
    #
    # @example Fetching a key that is allowed to be stale.
    #   response = Imperium::KV.get('foo/bar', :stale) # => KVGETResponse...
    #
    # @example Fetching a prefix recursively allowing values to be stale.
    #   response = Imperium::KV.get('foo/bar', :stale, :recurse) # => KVGETResponse...
    #
    # @todo Support blocking queries by accepting an :index parameter
    #
    # @param [String] key The key/prefix to be fetched from Consul.
    # @param [Array<Symbol,String,Hash>] options The options for constructing
    #   the request
    # @option options [Symbol] :consistent Specify the consistent option to the
    #   API resulting in the most up to date value possible at the expense of a
    #   bit of latency and the requirement of a validly elected leader. See
    #   {https://www.consul.io/docs/agent/http.html#consistency-modes Consistency Modes documentation}.
    # @option options [Symbol] :stale Specify the stale option to the API
    #   resulting in a potentially stale value with the benefit of a faster,
    #   more scaleable read. See
    #   {https://www.consul.io/docs/agent/http.html#consistency-modes Consistency Modes documentation}.
    # @option options [Symbol] :recurse Supply the recurse option to the API to
    #   fetch any keys with the specified prefix.
    # @option options [Symbol] :keys Fetch only the keys with the specified prefix.
    # @option options [String] :separator See
    #   {https://www.consul.io/docs/agent/http/kv.html#get-method Consul's Documentation}
    # @return [KVGETResponse]
    def get(key, *options)
      expanded_options = hashify_options(options)
      query_params = extract_query_params(expanded_options, allowed_params: GET_ALLOWED_OPTIONS)
      response = @http_client.get(prefix_path(key), query: query_params)
      KVGETResponse.new(response, prefix: key, options: expanded_options)
    end

    # Update or create the specified key
    # @note This is really a stub of this method, it will put the key but
    #   you'll get back a raw
    #   {http://www.rubydoc.info/gems/httpclient/HTTP/Message HTTP::Message}
    #   object. If you're really serious about using this we'll probably want
    #   to build a wrapper around the response with some logic to simplify
    #   interpreting the response.
    #
    # @param key [String] The key to be created or updated.
    # @param value [String] The value to be set on the key.
    # @param options [Array] Un-used, only here to prevent changing the method
    #   signature when we actually implement more advanced functionality.
    # @return [HTTP::Message]
    def put(key, value, *options)
      @http_client.put(prefix_path(key), value)
    end

    private

    def construct_nested_hash(key_parts, value)
      key = key_parts.shift
      if key_parts.empty?
        {key => value}
      else
        {key => construct_nested_hash(key_parts, value)}
      end
    end
  end
end
