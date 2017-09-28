require_relative 'refinements/hash_compact'
module Imperium
  # Base class for handling data coming from the Consul API
  class APIObject
    using HashCompact

    class << self
      # The mapping of attribute names coming from Consul to names that are more
      # Ruby friendly
      # @return [Hash<String => Symbol>]
      attr_reader :attribute_map

      # The Ruby friendly names from {attribute_map}
      # @return [Array<Symbol>]
      attr_reader :ruby_attribute_names

      def attribute_map=(val)
        @attribute_map = val
        @ruby_attribute_names = val.values.map(&:to_sym)
        attr_accessor *@ruby_attribute_names
      end
    end

    # Initialize a new object extracting attributes from the supplied hash
    def initialize(attributes = {})
      self.class.attribute_map.each do |key, attribute_name|
        value = attributes[attribute_name] || attributes[key]
        send("#{attribute_name}=", value) if value
      end
    end

    def ==(other)
      return false unless self.class == other.class
      ruby_attribute_names.all? { |attr| self.send(attr) == other.send(attr) }
    end

    def attribute_map
      self.class.attribute_map
    end

    # Shortcut method to access the class level attribute
    # @return [Array<Symbol>]
    def ruby_attribute_names
      self.class.ruby_attribute_names
    end

    # Convert the object and any sub-objects into a hash
    #
    # @param consul_names_as_keys [Boolean] Use the Consul object attribute names
    #   as the keys when true (default) otherwise use the ruby attribute names.
    def to_h(consul_names_as_keys: true)
      if consul_names_as_keys
        attribute_map.each_with_object({}) do |(consul, ruby), h|
          h[consul] = maybe_hashified_attribute(ruby, true)
        end.compact
      else
        ruby_attribute_names.each_with_object({}) do |attr, h|
          h[attr] = maybe_hashified_attribute(attr, false)
        end.compact
      end
    end

    private

    def maybe_hashified_attribute(attr_name, consul_names)
      val = send(attr_name)

      if val.nil?
        nil
      elsif val.is_a?(Array)
        val.map { |elem| elem.respond_to?(:to_h) ? fancy_send_to_h(elem, consul_names) : elem }
      elsif val.respond_to?(:to_h)
        fancy_send_to_h(val, consul_names)
      else
        val
      end
    end

    def fancy_send_to_h(obj, consul_names)
      (obj.is_a?(APIObject) ? obj.to_h(consul_names_as_keys: consul_names) : obj.to_h)
    end
  end
end
