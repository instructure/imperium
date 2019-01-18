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

  describe 'index' do
    it 'must return the value from the X-Consul-Index header cast to an integer' do
      message.http_header.add('X-Consul-Index', '1485002')
      expect(response.index).to eq 1485002
    end

    it 'must return nil when the X-Consul-Index header is unset' do
      expect(response.index).to be_nil
    end

    it 'must return nil when the X-Consul-Index header exists but cannot be parsed as an integer' do
      message.http_header.add('X-Consul-Index', 'hello')
      expect(response.index).to be_nil
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

  describe '#coerced_body' do
    let(:klass) { Class.new(Imperium::APIObject) { self.attribute_map = {'Foo' => :foo} } }

    it 'must return the parsed body when no response_object_class is specified' do
      message = HTTP::Message.new_response({foo: 'bar'}.to_json)
      local_response = Imperium::Response.new(message)
      expect(local_response.coerced_body).to eq "foo" => "bar"
    end

    it 'must coerce an array of objects into the specified type' do
      message = HTTP::Message.new_response([{Foo: 'bar'}, {Foo: 'baz'}].to_json)
      local_response = Imperium::Response.new(message, response_object_class: klass)
      expect(local_response.coerced_body).to be_a(Array)
      expect(local_response.coerced_body).to all(be_a(klass))
    end

    it 'must coerce a hash of objects in to the specified type maintaining the hash structure' do
      local_message = HTTP::Message.new_response({
        bar: {'Foo' => 'bar'},
        baz: {'Foo' => 'baz'},
      }.to_json)
      local_response = Imperium::Response.new(local_message, response_object_class: klass)
      expect(local_response.coerced_body).to be_a(Hash)
      expect(local_response.coerced_body['bar']).to be_a(klass)
      expect(local_response.coerced_body['baz']).to be_a(klass)
    end
  end
end
