require "spec_helper"

RSpec.describe Imperium do
  describe '.configure' do
    it 'must call the supplied block' do
      called = false
      Imperium.configure {|c| called = true }
      expect(called).to eq true
    end

    it 'must yield the configuration to the supplied block' do
      Imperium.configure do |config|
        expect(config).to eq Imperium.configuration
      end
    end
  end

  describe '.configuration' do
    it 'must return a Configuration object' do
      expect(Imperium.configuration).to be_a(Imperium::Configuration)
    end

    it 'must cache the constructed object' do
      config_1 = Imperium.configuration
      config_2 = Imperium.configuration
      expect(config_1.object_id).to eq config_2.object_id
    end
  end
end
