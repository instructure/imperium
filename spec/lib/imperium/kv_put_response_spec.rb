require 'spec_helper'

RSpec.describe Imperium::KVPUTResponse do
  let(:message) { HTTP::Message.new_response('') }
  let(:response) { Imperium::KVPUTResponse.new(message) }

  describe '#success?' do
    it 'must return true when "true\n" is the message body' do
      message.body << "true\n"
      expect(response.success?).to eq true
    end

    it 'must return false when "false\n" is the message body' do
      message.body << "false\n"
      expect(response.success?).to eq false
    end

    it 'must return false if the response body is empty' do
      expect(response.success?).to eq false
    end

    it 'must return false if the response status is 403' do
      message.body << "rpc error: rpc error: Permission denied\n"
      message.status = 403
      expect(response.success?).to eq false
    end
  end
end
