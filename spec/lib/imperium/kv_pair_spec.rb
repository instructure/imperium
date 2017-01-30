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

  describe '#initialize(attributes = {})' do
    it 'must extract the lock_index value from the LockIndex field' do
      expect(pair.lock_index).to eq 42
    end

    it 'must extract the session value from the Session field' do
      expect(pair.session).to eq 'adf4238a-882b-9ddc-4a9d-5b6758e4159e'
    end

    it 'must extract the key value from the Key field' do
      expect(pair.key).to eq 'foo/bar'
    end

    it 'must extract the flags value from the Flags field' do
      expect(pair.flags).to eq 0
    end

    it 'must extract the value value from the Value field and decode it' do
      expect(pair.value).to eq value
    end

    it 'must extract the create_index value from the CreateIndex field' do
      expect(pair.create_index).to eq 481
    end

    it 'must extract the modify_index value from the ModifyIndex field' do
      expect(pair.modify_index).to eq 481
    end
  end

  describe '#==(other)' do
    it 'must return false when another type of object is passed' do
      expect(pair).to_not eq 'wrong-type'
    end

    it 'must return false one or more of the attributes have changed' do
      other_pair = Imperium::KVPair.new(response_object)
      other_pair.key = 'other/key'
      expect(pair).to_not eq other_pair
    end

    it 'must return true when all the attributes are the same' do
      other_pair = Imperium::KVPair.new(response_object)
      expect(pair).to eq other_pair
    end
  end
end
