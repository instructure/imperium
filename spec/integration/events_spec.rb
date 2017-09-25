require 'spec_helper'
require 'net/http'

RSpec.describe 'events working w/ a real consul instance', :integration do
  before(:all) do
    Imperium.configure do |config|
      config.url = "http://#{ENV.fetch('IMPERIUM_CONSUL_HOST')}:#{ENV.fetch('IMPERIUM_CONSUL_PORT', 8500)}"
      config.ssl = ENV['IMPERIUM_CONSUL_SSL'] == 'true'
      config.token = ENV['IMPERIUM_CONSUL_TOKEN']
    end
    WebMock.allow_net_connect!
  end

  after(:all) do
    Imperium.configure do |config|
      config.url = 'http://localhost:8500'
      config.token = nil
    end
    WebMock.disable_net_connect!
  end

  let(:client) { Imperium::Events.default_client }

  describe 'firing events' do
    it 'works' do
      response = client.fire("event", "payload")
      expect(response.status).to eq 200
    end
  end
end
