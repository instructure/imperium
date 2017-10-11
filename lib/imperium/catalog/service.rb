require_relative '../api_object'

module Imperium
  class Catalog
    # Service is a container for data being received from and sent to the
    # catalog APIs.
    #
    # @see https://www.consul.io/api/catalog.html#list-nodes-for-service The Consul Catalog Documentation
    #
    # @!attribute [rw] id
    #   @return [String]
    # @!attribute [rw] node
    #   @return [String]
    # @!attribute [rw] address
    #   @return [String]
    # @!attribute [rw] datacenter
    #   @return [String]
    # @!attribute [rw] tagged_addresses
    #   @return [Hash<String => String>]
    # @!attribute [rw] node_meta
    #   @return [Hash<String => String>]
    # @!attribute [rw] service_id
    #   @return [String]
    # @!attribute [rw] service_name
    #   @return [String]
    # @!attribute [rw] service_address
    #   @return [String]
    # @!attribute [rw] service_tags
    #   @return [Array<String>]
    # @!attribute [rw] service_port
    #   @return [String]
    # @!attribute [rw] service_enable_tag_override
    #   @return [Boolean]
    # @!attribute [rw] create_index
    #   @return [Integer]
    # @!attribute [rw] modify_index
    #   @return [Integer]
    class Service < APIObject
      self.attribute_map = {
	'ID' => :id,
	'Node' => :node,
	'Address' => :address,
	'Datacenter' => :datacenter,
	'TaggedAddresses' => :tagged_addresses,
	'NodeMeta' => :node_meta,
	'ServiceID' => :service_id,
	'ServiceName' => :service_name,
	'ServiceAddress' => :service_address,
	'ServiceTags' => :service_tags,
	'ServicePort' => :service_port,
	'ServiceEnableTagOverride' => :service_enable_tag_override,
	'CreateIndex' => :create_index,
	'ModifyIndex' => :modify_index,
      }

      def initialize(*args)
        @tagged_addresses = {}
        @node_meta = {}
        @service_tags = []
        super
      end

      def tagged_addresses=(val)
        @tagged_addresses = (val.nil? ? {} : val)
      end

      def node_meta=(val)
        @node_meta = (val.nil? ? {} : val)
      end

      def service_tags=(val)
        @service_tags = (val.nil? ? [] : val)
      end
    end
  end
end
