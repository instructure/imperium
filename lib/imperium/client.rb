require 'base64'
require 'json'

module Imperium
  class Client
    # Options that are allowed for all API endpoints
    UNIVERSAL_API_OPTIONS = %i{dc}.freeze

    class << self
      attr_reader :subclasses
      attr_accessor :path_prefix

      def default_client
        @default_client ||= new(Imperium.configuration)
      end

      def reset_default_client
        @default_client = nil
      end
    end

    @subclasses = []
    def self.inherited(subclass)
      @subclasses << subclass
    end

    def self.reset_default_clients
      @subclasses.each(&:reset_default_client)
    end

    attr_reader :config

    def initialize(config)
      @config = config
      @http_client = Imperium::HTTPClient.new(config)
    end

    def path_prefix
      self.class.path_prefix
    end

    private

    def extract_query_params(full_options, allowed_params: :all)
      if full_options.key?(:consistent) && full_options.key?(:stale)
        raise InvalidConsistencySpecification, 'Both consistency modes (consistent, stale) supplied, this is not allowed by the HTTP API'
      end
      allowed_params == :all ?
        full_options :
        full_options.select { |k, _|
          allowed_params.include?(k.to_sym) || UNIVERSAL_API_OPTIONS.include?(k.to_sym)
        }
    end

    def hashify_options(options_array)
      options_array.inject({}) { |hash, value|
        value.is_a?(Hash) ? hash.merge(value) : hash.merge(value.to_sym => nil)
      }
    end

    def prefix_path(main_path, prefix = self.path_prefix)
      "#{prefix}/#{main_path}"
    end
  end
end
