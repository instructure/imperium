require 'spec_helper'
require 'imperium/testing'

RSpec.describe Imperium::Testing do
  describe '.kv_get_response' do
    it 'must return a valid response without any arguments' do
      response = Imperium::Testing.kv_get_response
      expect(response).to be_a Imperium::KVGETResponse
    end

    it 'must convert an array body to json and base64 encode any values found' do
      response = Imperium::Testing.kv_get_response(
        body: [{Value: 'foo'}]
      )
      expect(response.content).to eq [{'Value' => Base64.encode64('foo')}].to_json
    end
  end
end
