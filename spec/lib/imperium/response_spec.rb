require 'spec_helper'

RSpec.describe Imperium::Response do
  let(:message) { HTTP::Message.new_response('{}') }
  let(:response) { Imperium::Response.new(message) }

  describe 'known_leader?' do
    it 'must return false when the X-Consul-KnownLeader header is set to "false"' do
      message.http_header.add('X-Consul-KnownLeader', 'false')
      expect(response.known_leader?).to eq false
    end

    it 'must return true when the X-Consul-KnownLeader header is set to "true"' do
      message.http_header.add('X-Consul-KnownLeader', 'true')
      expect(response.known_leader?).to eq true
    end
    it 'must return nil when the X-Consul-KnownLeader header is unset' do
      expect(response.known_leader?).to be_nil
    end
  end

  describe 'last_contact' do
    it 'must return the value from the X-Consul-LastContact header cast to an integer' do
      message.http_header.add('X-Consul-LastContact', '250')
      expect(response.last_contact).to eq 250
    end

    it 'must return nil when the X-Consul-LastContact header is unset' do
      expect(response.last_contact).to be_nil
    end
  end

  describe 'translate_addresses?' do
    it 'must return true when the X-Consul-Translate-Addresses header is set' do
      message.http_header.add('X-Consul-Translate-Addresses', 'true')
      expect(response.translate_addresses?).to eq true
    end

    it 'must return false when the X-Consul-KnownLeader header is unset' do
      expect(response.translate_addresses?).to eq false
    end
  end
end
