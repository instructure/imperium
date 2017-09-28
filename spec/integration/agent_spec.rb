require 'spec_helper'
require 'net/http'

RSpec.describe 'The Agent client working with a real consul instance', :integration do
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

  let(:client) { Imperium::Agent.default_client }
  let(:service) { Imperium::Service.new('ID' => 'foobar', 'Name' => 'baz') }
  let(:consul_url) { Imperium.configuration.url.dup }

  it 'must be able to list the services registered with the local agent' do
    services = client.list_services
    expect(services).to all(be_a(Imperium::Service))
    service_ids = services.map(&:id)
    expect(service_ids).to include 'consul'
  end

  describe '#list_checks' do
    before do
      service.add_check({ttl: '100h', name: 'boo'})
      client.register_service(service)
    end

    after do
      client.deregister_service(service)
    end

    it 'must include checks registered by service registrations' do
      checks_response = client.list_checks
      expect(checks_response['service:foobar']).to be_a(Imperium::ServiceCheck)
    end
  end

  describe 'Registering a new service with an agent' do
    let(:dereg_url) {
      consul_url.tap {|url| url.path = "/v1/agent/service/deregister/#{service.id}" }
    }

    after do
      Net::HTTP.start(dereg_url.host, dereg_url.port) do |http|
        http.request(Net::HTTP::Put.new(dereg_url))
      end
    end

    it 'must register the supplied service' do
      initial_services = client.list_services
      initial_service_ids = initial_services.map(&:id)
      expect(initial_service_ids).to_not include(service.id), "Test unable to proceed, service #{service.id} is already registered."

      client.register_service(service)
      found_services = client.list_services
      service_ids = found_services.map(&:id)
      expect(service_ids).to include service.id
    end
  end

  describe 'Deregistering a service from the local registry' do
    let(:reg_url) {
      consul_url.tap {|url| url.path = "/v1/agent/service/register" }
    }

    before do
      Net::HTTP.start(reg_url.host, reg_url.port) do |http|
        http.request(Net::HTTP::Put.new(reg_url), JSON.generate(service.registration_data))
      end

      initial_services = client.list_services
      initial_service_ids = initial_services.map(&:id)
      expect(initial_service_ids).to include(service.id), "Test unable to proceed, service #{service.id} failed to register."
    end

    it 'must work when supplied a Service object' do
      client.deregister_service(service)
      found_services = client.list_services
      service_ids = found_services.map(&:id)
      expect(service_ids).to_not include(service.id), "Expected service #{service.id} to be deregistered but it still exists in consul"
    end

    it 'must work when supplied a service ID string' do
      client.deregister_service(service.id)
      found_services = client.list_services
      service_ids = found_services.map(&:id)
      expect(service_ids).to_not include(service.id), "Expected service #{service.id} to be deregistered but it still exists in consul"
    end
  end
end
