require_relative 'api_object'
require 'base64'

module Imperium
  # KVPair provides a more OO/Rubyish interface to the objects returned from
  # the KV API on a GET request.
  #
  # @see https://www.consul.io/docs/agent/http/kv.html#get-method Consul KV GET Documentation
  #
  # @!attribute [rw] lock_index
  #   @return [Integer] The number of times this key has successfully been
  #     locked, the {#session} attribute indicates which session owns the lock.
  # @!attribute [rw] session
  #   @return [String] The identifier for the session that owns the lock.
  # @!attribute [rw] key
  #   @return [String] The full path for the entry.
  # @!attribute [rw] flags
  #   @return [Integer] An opaque unsigned integer for use by the client
  #     application.
  # @!attribute [rw] value
  #   @return [String] The stored value (returned already base64 decoded)
  # @!attribute [rw] create_index
  #   @return [Integer] The internal index value representing when the entry
  #     was created.
  # @!attribute [rw] modify_index
  #   @return [Integer] The internal index value representing when the entry
  #     was last updated.
  class KVPair < APIObject
    self.attribute_map = {
      'LockIndex' => :lock_index,
      'Session' => :session,
      'Key' => :key,
      'Flags' => :flags,
      'Value' => :value,
      'CreateIndex' => :create_index,
      'ModifyIndex' => :modify_index,
    }.freeze

    # Capture and base64 decode a value from the api.
    #
    # @param value [String] The base64 encoded value from the response.
    def value=(value)
      return @value = nil if value.nil?
      @value = Base64.decode64 value
    end
  end
end
