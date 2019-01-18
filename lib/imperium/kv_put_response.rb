require_relative 'response'

module Imperium
  # KVPUTResponse is a wrapper for the raw HTTP::Message response from the API
  #
  # @note This class doesn't really make sense to be instantiated outside of
  #   {KV#put}
  #
  # @!attribute [rw] options
  #   @return [Hash<Symbol, Object>] The options for the get request after being
  #   coerced from an array to hash.
  class KVPUTResponse < Response
    attr_accessor :options

    def initialize(message, options: {})
      super message
      @options = options
    end

    if RUBY_VERSION < "2.4"
      def success?
        return @success if defined? @success
        @success = (body.chomp == "true")
      end
    else
      def success?
        return @success if defined? @success
        @success = JSON.parse(body)
      rescue JSON::ParserError
        (status == 403 or body.empty?) ?
          @success = false : raise
      end
    end
  end
end
