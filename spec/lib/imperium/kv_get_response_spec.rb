require 'spec_helper'

RSpec.describe Imperium::KVGETResponse do
  let(:message) { HTTP::Message.new_response('') }
  let(:response) { Imperium::KVGETResponse.new(message) }
  let(:single_object) {
    {'LockIndex' => 42, 'Session' => 'adf4238a-882b-9ddc-4a9d-5b6758e4159e', 'Key' => 'foo/bar', 'Flags' => 0, 'Value' => Base64.encode64('baz'), 'CreateIndex' => 481, 'ModifyIndex' => 481}
  }
  let(:single_object_response) { [single_object].to_json }

  describe '#found_objects' do
    it 'must return nil when only keys are requested' do
      response.options = {keys: true}
      expect(response.found_objects).to be_nil
    end

    it 'must return the array of objects returned from the api' do
      message.body << single_object_response
      expect(response.found_objects).to eq [Imperium::KVPair.new(single_object)]
    end

    it 'must return an empty array when the response status code is 404' do
      message.status = 404
      expect(response.found_objects).to eq []
    end
  end

  describe '#prefix=(value)' do
    it 'must strip off a trailing slash if present' do
      response.prefix = 'foo/'
      expect(response.prefix).to eq 'foo'
    end

    it 'must set the prefix to nil when passed nil' do
      response.prefix = nil
      expect(response.prefix).to be_nil
    end
  end

  describe '#values' do
    let(:deeply_nested_response) {[
      {"LockIndex" => 0, "Key" => "foo/bar/baz/first", "Flags" => 0, "Value" => Base64.encode64('qux'), "CreateIndex" => 657, "ModifyIndex" => 657},
      {"LockIndex" => 0, "Key" => "foo/bar/baz/second/deep", "Flags" => 0, "Value" => Base64.encode64('purple'), "CreateIndex" => 657, "ModifyIndex" => 657},
    ].to_json}

    it 'must return nil when the response is a 404' do
      message.status = 404
      expect(response.values).to be_nil
    end

    it 'must return the parsed array when just keys are requested' do
      response.options = {keys: true}
      message.body << %w{foo/bar/baz foo/bar/qux boing}.to_json
      expect(response.values).to contain_exactly *%w{foo/bar/baz foo/bar/qux boing}
    end

    it 'must return the string value when only one value is requested and returned' do
      message.body << single_object_response
      expect(response.values).to eq 'baz'
    end

    context 'with the recurse option set' do
      before do
        response.options = {recurse: true}
        response.prefix = 'foo/bar'
      end

      it 'must return the string value for a single key that exactly matches the supplied prefix' do
        message.body << single_object_response
        expect(response.values).to eq 'baz'
      end

      it 'must return a hash when one nested value returned' do
        message.body << single_object_response
        response.prefix = 'foo'
        expect(response.values).to eq({'bar' => 'baz'})
      end

      it 'must not chop off the first letter of keys when the prefix is an empty string' do
        message.body << single_object_response
        response.prefix = ''
        expect(response.values).to eq({'foo' => {'bar' => 'baz'}})
      end

      it 'must return a nested hash when many values are returned' do
        message.body << deeply_nested_response
        expect(response.values).to eq({
          'baz' => {
            'first' => 'qux',
            'second' => {'deep' => 'purple'}
          }
        })
      end
    end
  end
end
