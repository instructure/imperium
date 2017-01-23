require 'spec_helper'

RSpec.describe Imperium::Client do
  let(:klass) { Class.new(Imperium::Client) }

  after do
    Imperium::Client.subclasses.delete(klass)
  end

  describe '.default_client' do
    it 'must return a new instance of the subclass' do
      expect(klass.default_client).to be_a klass
    end

    it 'must always return the same instance' do
      client_1 = klass.default_client
      client_2 = klass.default_client
      expect(client_1.object_id).to eq client_2.object_id
    end
  end

  describe '.reset_default_client' do
    it 'must cause .default_client to generate a new object' do
      client_1 = klass.default_client
      klass.reset_default_client
      client_2 = klass.default_client
      expect(client_1.object_id).to_not eq client_2.object_id
    end
  end

  describe '.reset_default_clients' do
    it 'must cause all subclasses to reset their default clients' do
      expect(klass).to receive(:reset_default_client)
      Imperium::Client.reset_default_clients
    end
  end
end
