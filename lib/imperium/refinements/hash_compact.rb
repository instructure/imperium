module Imperium
  module HashCompact
    refine Hash do
      unless Hash.instance_methods(false).include?(:compact)
        def compact
          reject { |_, v| v.nil? }
        end
      end
    end
  end
end
