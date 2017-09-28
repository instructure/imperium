require_relative 'response'
require_relative 'service_check'

module Imperium
  class AgentListChecksResponse < Response
    self.default_response_object_class = ServiceCheck

    def checks
      @checks ||= checks_hash.values
    end

    def checks_hash
      @checks_hash ||= (ok? ? coerced_body : {})
    end

    def [](key)
      checks_hash[key]
    end

    def each(&block)
      checks.each(&block)
    end
  end
end
