require 'spec_helper'

RSpec.describe Imperium::KVPair do
  let(:value) { 'baz' }
  let(:response_object) {
    {
      'LockIndex' => 42,
      'Session' => 'adf4238a-882b-9ddc-4a9d-5b6758e4159e',
      'Key' => 'foo/bar',
      'Flags' => 0,
      'Value' => Base64.encode64(value),
      'CreateIndex' => 481,
      'ModifyIndex' => 481,
    }
  }
  let(:pair) { Imperium::KVPair.new(response_object) }
  let(:empty_pair) { Imperium::KVPair.new }

  describe '#value=' do
    it 'must base64 decode legit values' do
      empty_pair.value = Base64.encode64('foobar')
      expect(empty_pair.value).to eq 'foobar'
    end

    it 'must accept a nil value without failing' do
      expect(pair.value).to_not be_nil
      pair.value = nil
      expect(pair.value).to be_nil
    end
  end
end
