module Imperium
  # Service is a container for data being received from and sent to the agent
  # services APIs.
  #
  # @see https://www.consul.io/api/agent/service.html Agent Services API documentation
  #
  # @!attribute [rw] id
  #   @return [String] The service's id, when creating a new service this will
  #     be automatically assigned if not supplied, must be unique.
  # @!attribute [rw] name
  #   @return [String] The service's name in the consul UI, required for
  #     creation, not required to be unique.
  # @!attribute [rw] tags
  #   @return [Arary<String>] List of tags to be used for the service, can be
  #     used after creation for filtering in the API.
  # @!attribute [rw] address
  #   @return [String] The network address to find the service at for DNS
  #     requests, defaults to the running agent's IP if left blank.
  # @!attribute [rw] port
  #   @return [Integer] The port the service is bound to for network services.
  # @!attribute [rw] checks
  #   @return [Array<ServiceCheck>] Specifies a list of checks to use for monitoring
  #     the service's health.
  # @!attribute [rw] enable_tag_override
  #   @return [Boolean] Specifies to disable the anti-entropy feature for this
  #     service's tags. If EnableTagOverride is set to true then external agents
  #     can update this service in the catalog and modify the tags.
  # @!attribute [r] create_index
  #   @return [Integer]
  # @!attribute [r] modify_index
  #   @return [Integer]
  class Service < APIObject
    self.attribute_map = {
      'ID' => :id,
      'Name' => :name,
      'Tags' => :tags,
      'Address' => :address,
      'Port' => :port,
      'Check' => :check,
      'Checks' => :checks,
      'EnableTagOverride' => :enable_tag_override,
      'CreateIndex' => :create_index,
      'ModifyIndex' => :modify_index
    }

    def initialize(*args)
      # So we can << onto these w/o having to nil check everywhere first
      @tags ||= []
      @checks ||= []
      super
    end

    def add_check(val)
      @checks <<  maybe_convert_service_check(val) unless val.nil?
    end
    alias check= add_check


    def checks=(val)
      @checks = (val || []).map { |obj| maybe_convert_service_check(obj) }
    end

    def tags=(val)
      @tags = (val.nil? ? [] : val)
    end

    # Generate a hash containing the data necessary for registering this service.
    #
    # If both Check and Checks are present in the object they're coalesced into
    # a single Checks key.
    #
    # @return [Hash<String => String,Integer,Hash<String => String>,Array<Hash<String => String>>]
    def registration_data
      to_h.tap do |h|
        h.delete('CreateIndex')
        h.delete('ModifyIndex')
        h.delete('Checks') if checks.empty?
      end
    end

    private

    def maybe_convert_service_check(attrs_or_check)
      attrs_or_check.is_a?(Hash) ? ServiceCheck.new(attrs_or_check) : attrs_or_check
    end
  end
end
