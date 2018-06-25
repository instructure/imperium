module Imperium
  # A client for the KV API.
  class KV < Client
    self.path_prefix = 'v1/kv'.freeze

    # {#get GET} a key using the {.default_client}
    # @see #get
    def self.get(key, *options)
      default_client.get(key, *options)
    end

    # {#put Create or update} a key using the {.default_client}
    # @see #put
    def self.put(key, value, *options)
      default_client.put(key, value, *options)
    end

    # {#delete DELETE} a key using the {.default_client}
    # @see #delete
    def self.delete(key, *options)
      default_client.delete(key, *options)
    end

    GET_ALLOWED_OPTIONS = %i{consistent stale recurse keys separator raw}.freeze
    private_constant :GET_ALLOWED_OPTIONS

    PUT_ALLOWED_OPTIONS = %i{flags cas acquire release}.freeze
    private_constant :PUT_ALLOWED_OPTIONS

    DELETE_ALLOWED_OPTIONS = %i{cas}.freeze
    private_constant :DELETE_ALLOWED_OPTIONS

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
    # @option options [String] :dc Specify the datacenter to use for the request
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
    #
    # @param key [String] The key to be created or updated.
    # @param value [String] The value to be set on the key.
    # @param [Array<Symbol,String,Hash>] options The options for constructing
    #   the request
    # @option options [String] :dc Specify the datacenter to use for the request
    # @option options [Integer] :flags Specifies an unsigned value
    #   between 0 and (2^64)-1. Clients can choose to use this however makes
    #   sense for their application.
    # @option options [Integer] :cas Specifies to use a Check-And-Set operation.
    #   This is very useful as a building block for more complex synchronization
    #   primitives. If the index is 0, Consul will only put the key if it does
    #   not already exist. If the index is non-zero, the key is only set if the
    #   index matches the ModifyIndex of that key.
    # @option options [String] :acquire Supply a session key for use in
    #   acquiring lock on the key. From the Consul docs: Specifies to use a lock
    #   acquisition operation. This is useful as it allows leader election to be
    #   built on top of Consul. If the lock is not held and the session is
    #   valid, this increments the LockIndex and sets the Session value of the
    #   key in addition to updating the key contents. A key does not need to
    #   exist to be acquired. If the lock is already held by the given session,
    #   then the LockIndex is not incremented but the key contents are updated.
    #   This lets the current lock holder update the key contents without having
    #   to give up the lock and reacquire it.
    # @option options [String] :release Supply a session key for releasing a
    #   lock. From the Consul docs: Specifies to use a lock release operation.
    #   This is useful when paired with ?acquire= as it allows clients to yield
    #   a lock. This will leave the LockIndex unmodified but will clear the
    #   associated Session of the key. The key must be held by this session to
    #   be unlocked.
    # @return [KVPUTResponse]
    def put(key, value, *options)
      expanded_options = hashify_options(options)
      query_params = extract_query_params(expanded_options, allowed_params: PUT_ALLOWED_OPTIONS)
      response = @http_client.put(prefix_path(key), value, query: query_params)
      KVPUTResponse.new(response, options: expanded_options)
    end

    # Delete the specified key
    #
    # @todo Decide whether to support recursive deletion by accepting the
    #   :recurse parameter
    #
    # @param key [String] The key to be created or updated.
    # @param [Array<Symbol,String,Hash>] options The options for constructing
    #   the request
    # @option options [String] :dc Specify the datacenter to use for the request
    # @option options [Integer] :cas Specifies to use a Check-And-Set operation.
    #   This is very useful as a building block for more complex synchronization
    #   primitives. Unlike PUT, the index must be greater than 0 for Consul to
    #   take any action: a 0 index will not delete the key. If the index is
    #   non-zero, the key is only deleted if the index matches the ModifyIndex
    #   of that key.
    # @return [KVDELETEResponse]
    def delete(key, *options)
      expanded_options = hashify_options(options)
      query_params = extract_query_params(expanded_options, allowed_params: DELETE_ALLOWED_OPTIONS)
      response = @http_client.delete(prefix_path(key), query: query_params)
      KVDELETEResponse.new(response, options: expanded_options)
    end

    # Perform operation in the transaction
    #
    #   This is useful when having a number of statements that must be executed
    #   together or not at all.
    #
    #   @yieldparam [Transaction] a Transaction instance that can be used to
    #     perform operations in the transaction
    # @return [TransactionResponse]
    def transaction
      tx = Imperium::Transaction.new
      yield tx
      response = @http_client.put('v1/txn', tx.body)
      Imperium::TransactionResponse.new(response)
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
