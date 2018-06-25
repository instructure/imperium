require 'spec_helper'
require 'json'

RSpec.describe Imperium::TransactionResponse do
  let(:key) {'key'}
  let(:value) {'value'}
  let(:kv_message) {double("Message", content: {
    'Results' => [
      'KV' => {
        'Key' => key,
        'Value' => Base64.encode64(value),
      }
    ]
  }.to_json)}
  let(:kv_response) { Imperium::TransactionResponse.new(kv_message) }
  let(:no_kv_message) {double("Message", content: {
    'Results' => [
      'foo' => {
        'Key' => key,
        'Value' => Base64.encode64(value),
      }
    ]
  }.to_json)}
  let(:no_kv_response) { Imperium::TransactionResponse.new(no_kv_message) }

  describe '#results' do
    it 'creates a well-formed result when KV exists' do
      result = kv_response.results.first
      expect(result.key).to eq(key)
    end

    it 'does not create a KV result when KV does not exist' do
      result = no_kv_response.results.first
      expect(result).to be_nil
    end
  end

  let(:errors_message) {double("Message", content: {'Errors' => ['baz' => {'foo' => 'bar'}]}.to_json)}
  let(:errors_response) { Imperium::TransactionResponse.new(errors_message) }

  describe '#errors' do
    it 'generates errors message when errors exist' do
      expect(errors_response.errors).not_to be_empty
    end

    it 'does not generate errors message when no error' do
      expect(kv_response.errors).to be_nil
    end
  end
end
