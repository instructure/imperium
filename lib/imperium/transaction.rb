module Imperium
  # A Transaction support for KV API
  class Transaction
    # Initializa a new transaction containing an array of
    # operations
    def initialize
      @operations = []
    end

    # {#set Set or Put} a key value pair
    # @see #set
    def set(key, value, flags: nil)
      add_operation('set', key, value: value, flags: flags)
    end

    # Get JSON object for operations
    #
    # @return JSON KV object
    def body
      @operations.to_json
    end

    # Add operation to a Transaction

    # @param verb [string] Specifies the type of operation to perform
    # @param key [string] Specifies the full path of the entry
    # @param value [string] Specifies a base64-encoded blob of data.
    #   Values cannot be larger than 512kB.
    # @param flags [int] Specifies an opaque unsigned integer that
    #   can be attached to each entry. Clients can choose to use this
    #   however makes sense for their application.
    # @param index [int] Specifies an index.
    # @param session [string] Specifies a session.
    #
    # @return list of operations to perform inside the atomic transaction
    def add_operation(verb, key, value: nil, flags: nil, index: nil, session_id: nil)
      kv = {
        'Verb' => verb,
        'Key' => key
      }
      kv['Value'] = Base64.encode64(value) if value
      kv['Flags'] = flags if flags
      kv['Index'] = index if index
      kv['Session'] = session_id if session_id
      @operations << { 'KV' => kv }
    end
  end
end
