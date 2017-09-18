require_relative 'response'

module Imperium
  # KVGETResponse is a wrapper for the raw HTTP::Message response from the API
  #
  # @note This class doesn't really make sense to be instantiated outside of
  #   {KV#get}
  #
  # @!attribute [rw] options
  #   @return [Hash<Symbol, Object>] The options for the get request after being
  #   coerced from an array to hash.
  # @attribute [rw] prefix
  #   @return [String] The key prefix requested from the api, used to coerce the
  #   returned values from the API into their various shapes.
  class KVGETResponse < Response
    attr_accessor :options, :prefix

    def initialize(message, options: {}, prefix: '')
      super message
      @prefix = prefix
      @options = options
    end

    # Construct an Array of KV pairs from a response, including their full
    # metadata.
    #
    # @return [nil] When the keys option was supplied.
    # @return [Array<KVPair>] When there are values present, and an empty array
    #   when the response is a 404.
    def found_objects
      return if options.key?(:keys)
      return [] if not_found?
      @found_objects ||= parsed_body.map { |attrs| KVPair.new(attrs) }
    end

    def prefix=(value)
      @prefix = (value.nil? ? nil : value.sub(/\/\z/, ''))
    end

    MERGING_FUNC = -> (_, old, new) {
      old_is_hash = old.is_a?(Hash)
      new_is_hash = new.is_a?(Hash)
      if old_is_hash && new_is_hash
        old.merge(new, &MERGING_FUNC)
      elsif new_is_hash
        new.merge(nil => old)
      else
        old.merge(nil => new)
      end
    }
    private_constant :MERGING_FUNC

    # Extracts the values from the response and smashes them into a simple
    # object depending on options provided on the request.
    #
    # If a value exists exactly at the prefix or exactly at a nested prefix
    # with additional nested values the hash representing the nested values
    # will have a `nil` key added to contain the un-nested value.
    #
    # @example A nested hash constructed from recursively found values
    #   # Given a response including the following values (metadata ommitted for clarity):
    #   # [
    #   #   {"Key" => "foo/bar/baz/first", "Value" => "cXV4Cg=="},
    #   #   {"Key" => "foo/bar/baz/second/deep", "Value" => "cHVycGxlCg=="}
    #   # ]
    #   response = Imperium::KV.get('foo/bar/baz', :recurse)
    #   response.values # => {'first' => 'qux', 'second' => {'deep' => 'purple'}}
    #
    # @example A nested hash constructed from recusively found values and repeated keys
    #   # Given a response including the following values (metadata ommitted for clarity):
    #   # [
    #   #   {"Key" => "foo/bar", "Value" => "b25l\n"},
    #   #   {"Key" => "foo/bar/baz", "Value" => "dHdv\n"}
    #   #   {"Key" => "foo/bar/baz/qux", "Value" => "dGhyZWU=\n"}
    #   # ]
    #   response = Imperium::KV.get('foo/bar', :recurse)
    #   response.values # => {
    #     nil => 'one',
    #     'baz' => {nil => 'two', qux' => 'three'},
    #   }
    # @return [String] When the matching key is found without the `recurse`
    #   option as well as when a single value is found with the recurse option
    #   and the key exactly matches the prefix.
    # @return [Hash{String => Hash,String}] When the recurse option is included
    #   and there are keys present nested within the prefix.
    # @return [Array<String>] An array of strings representing all of the keys
    #   within the specified prefix when the keys option is included.
    # @return [nil] When the response status code is 404 (Not Found)
    def values
      return if not_found?
      return parsed_body if options.key?(:keys)
      if options.key?(:recurse)
        if found_objects.size == 1 && found_objects.first.key == prefix
          found_objects.first.value
        else
          found_objects.inject({}) do |hash, obj|
            key_parts = extract_key_parts(obj.key)
            hash.merge(construct_nested_hash(key_parts, obj.value), &MERGING_FUNC)
          end
        end
      else
        found_objects.first.value
      end
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

    def extract_key_parts(key)
      unprefixed_key = remove_prefix(key)
      (unprefixed_key.nil? ? [nil] : unprefixed_key.split('/'))
    end

    def remove_prefix(key)
      prefix.empty? ? key : key[(prefix.length + 1)..-1]
      if prefix.empty?
        unprefixed_key = key
      else
        unprefixed_key = key[prefix.length + 1..-1]
      end
    end
  end
end
