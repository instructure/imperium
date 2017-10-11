require 'spec_helper'

RSpec.describe Imperium::Catalog do
  let(:client) { Imperium::Catalog.default_client }

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

  it 'must be able to list services in the catalog' do
    services = client.list_services
    expect(services.coerced_body).to include 'consul' => []
  end

  it 'must be able to list the nodes for a service' do
    nodes = client.list_nodes_for_service('consul')
    expect(nodes).to all(be_a(Imperium::Catalog::Service))
  end
end
