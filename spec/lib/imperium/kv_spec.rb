require 'spec_helper'

RSpec.describe Imperium::KV do
  let(:config) { double(Imperium::Configuration) }
  let(:http_client) { double(Imperium::HTTPClient) }
  let(:kv_client) { Imperium::KV.new(config) }

  let(:key) { 'foo/bar' }
  let(:value) { 'baz' }

  before do
    allow(config).to receive(:connect_timeout).and_return(5)
    allow(config).to receive(:send_timeout).and_return(5)
    allow(config).to receive(:receive_timeout).and_return(5)
    kv_client.instance_variable_set(:@http_client, http_client)
  end

  describe '#get(key, *options)' do
    let(:response) {
      double(HTTP::Message).tap { |resp| allow(resp).to receive_messages({body: response_body}) }
    }
    let(:response_body) {[
      {
        "LockIndex" => 0,
        "Key" => key,
        "Flags" => 0,
        "Value" => Base64.encode64(value),
        "CreateIndex" => 657,
        "ModifyIndex" => 657
      }
    ].to_json}

    before do
      allow(http_client).to receive(:get).
        with("v1/kv/#{key}", an_instance_of(Hash)).
        and_return(response)
    end

    it 'must add the v1/kv prefix to the key and pass it to the http client as the path' do
      kv_client.get(key)
      expect(http_client).to have_received(:get).
        with("v1/kv/#{key}", an_instance_of(Hash))
    end

    it 'must pass on a value when included' do
      kv_client.get(key, separator: 42)
      expect(http_client).to have_received(:get).
        with(an_instance_of(String), hash_including(query: hash_including(separator: 42)))
    end

    it 'must not pass on nonsensical options' do
      kv_client.get(key, :foo_bar)
      expect(http_client).to_not have_received(:get).
        with(an_instance_of(String), hash_including(query: hash_including(foo_bar: nil)))
    end

    it 'must treat lone keys as a nil value' do
      kv_client.get(key, :consistent)
      expect(http_client).to have_received(:get).
        with(an_instance_of(String), hash_including(query: hash_including(consistent: nil)))
    end

    it 'must raise an exception when both consistency modes are specified' do
      expect { kv_client.get(key, :consistent, :stale) }.to raise_error(Imperium::InvalidConsistencySpecification)
    end

    it 'must return a KVGETResponse object' do
      response = kv_client.get(key)
      expect(response).to be_a Imperium::KVGETResponse
    end

    it 'must pass on the requested key as the prefix attribute on the response' do
      response = kv_client.get(key)
      expect(response.prefix).to eq key
    end

    it 'must pass on the expanded options hash to the response object' do
      response = kv_client.get(key, :recurse)
      expect(response.options).to include recurse: nil
    end
  end

  describe '#put(key, value *options)' do
    let(:response) {
      double(HTTP::Message).tap { |resp| allow(resp).to receive_messages({body: response_body}) }
    }
    let(:response_body) { "true" }

    before do
      allow(http_client).to receive(:put)
        .with("v1/kv/#{key}", value, an_instance_of(Hash))
        .and_return(response)
    end

    it 'must add the v1/kv prefix to the key and pass it to the http client as the path' do
      kv_client.put(key, value)
      expect(http_client).to have_received(:put).
        with("v1/kv/#{key}", value, an_instance_of(Hash))
    end

    it 'must return a KVPUTResponse object' do
      response = kv_client.put(key, value)
      expect(response).to be_a Imperium::KVPUTResponse
    end
  end
  describe '#transaction(*options)' do
    let(:body) { "[{\"KV\":{\"Verb\":\"set\",\"Key\":\"foo/bar\",\"Value\":\"YmF6\\n\"}}]" }
    let(:response) {
      double(HTTP::Message).tap {|resp| allow(resp).to receive_messages({body: response_body})}
    }
    let(:response_body) {"true"}

    before do
      allow(http_client).to receive(:put)
                                .with("v1/txn", body, an_instance_of(Hash))
                                .and_return(response)
    end

    it 'must add the v1/txn prefix to the key and pass it to the http client as the path' do
      kv_client.transaction {|tx| tx.set(key, value)}
      expect(http_client).to have_received(:put).
          with("v1/txn", body, an_instance_of(Hash))
    end

    it 'must return a TransactionResponse object' do
      response = kv_client.transaction {|tx| tx.set(key, value)}
      expect(response).to be_a Imperium::TransactionResponse
    end

    it 'must set the dc if passed' do
      kv_client.transaction({dc: 'test'}) {|tx| tx.set(key, value)}
      expect(http_client).to have_received(:put).
          with("v1/txn", body, {query: {dc: 'test'}})
    end
  end
end
