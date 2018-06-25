require 'spec_helper'
require 'json'

RSpec.describe Imperium::Transaction do
  subject(:transaction) { Imperium::Transaction.new}
  let(:key) {'key'}
  let(:value) {'value'}
  let(:flags) {7}

  describe '#set' do
    it 'Base64 encodes the value' do
      transaction.set(key, value)
      body = JSON.parse(transaction.body)
      expect(body.first['KV']['Value']).to eq Base64.encode64(value)
    end

    it 'supports flags' do
      transaction.set(key, value, flags: flags)
      body = JSON.parse(transaction.body)
      expect(body.first['KV']['Flags']).to eq flags
    end
  end

  describe '#body' do
    it 'create a json body' do
      transaction.set(key, value, flags: flags)
      expect(JSON.parse(transaction.body)).to eq([{
        'KV' => {
          'Verb' => 'set',
          'Key' => key,
          'Value' => Base64.encode64(value),
          'Flags' => flags
        }
      }])
    end
  end

  describe '#add_operation' do
    it 'adds the correct SET operation' do
      transaction.add_operation('set', key, value: value)
      expect(JSON.parse(transaction.body)).to eq([{
        'KV' => {
          'Verb' => 'set',
          'Key' => key,
          'Value' => Base64.encode64(value)
        }
      }])
    end

    it 'adds the correct DELETE operation' do
      transaction.add_operation('delete', key)
      expect(JSON.parse(transaction.body)).to eq([{
        'KV' => {
          'Verb' => 'delete',
          'Key' => key
        }
      }])
    end

    it 'adds the correct GET operation' do
      transaction.add_operation('get', key)
      expect(JSON.parse(transaction.body)).to eq([{
        'KV' => {
          'Verb' => 'get',
          'Key' => key
        }
      }])
    end

    it 'adds the correct LOCK operation with multiple params given' do
      transaction.add_operation('lock', key, value: value, flags: flags, session_id: 'foo')
      expect(JSON.parse(transaction.body)).to eq([{
        'KV' => {
          'Verb' => 'lock',
          'Key' => key,
          'Value' => Base64.encode64(value),
          'Flags' => flags,
          'Session' => 'foo'
        }
      }])
    end
  end
end
