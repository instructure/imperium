module Imperium
  class Client
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

    def prefix_path(main_path, prefix = self.path_prefix)
      "#{prefix}/#{main_path}"
    end
  end
end
