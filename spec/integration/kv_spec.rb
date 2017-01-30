require 'spec_helper'
require 'net/http'

RSpec.describe 'KV store working w/ a real consul instance', :integration do
  before(:all) do
    Imperium.configure do |config|
      config.url = "http://#{ENV.fetch('IMPERIUM_CONSUL_HOST')}:#{ENV.fetch('IMPERIUM_CONSUL_PORT')}"
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

  let(:client) { Imperium::KV.default_client }

  describe 'PUTting keys' do
    let(:key) { 'imperium-tests/foo/bar' }
    let(:value) { 'baz' }
    let(:url) {
      Imperium.configuration.url.dup.tap {|url| url.path = "/v1/kv/#{key}" }
    }

    after do
      Net::HTTP.start(url.host, url.port) do |http|
        http.request(Net::HTTP::Delete.new(url))
      end
    end

    it 'must do enough to validate that querying keys works' do
      put_response = client.put(key, value)
      expect(put_response.status).to eq 200
      response = JSON.parse(Net::HTTP.get(url))
      expect(response.first['Value']).to eq 'YmF6'
    end
  end

  describe 'GETting keys' do
    before(:all) do
      Imperium::KV.default_client.put('imperium-tests/foo/bar', 'baz')

      # Single depth nesting of keys
      Imperium::KV.default_client.put('imperium-tests/nested/one', 'Nothing wrong with me')
      Imperium::KV.default_client.put('imperium-tests/nested/two', "Something's got to give")
    end

    after(:all) do
      Imperium::KV.default_client.delete('imperium-tests/foo/bar')
      Imperium::KV.default_client.delete('imperium-tests/nested/one')
      Imperium::KV.default_client.delete('imperium-tests/nested/two')
    end

    it 'must get a single value' do
      expect(client.get('imperium-tests/foo/bar').values).to eq 'baz'
    end

    it 'must get multiple values' do
      expect(client.get('imperium-tests/nested', :recurse).values).to eq({
        'one' => 'Nothing wrong with me',
        'two' => "Something's got to give"
      })
    end
  end

  describe 'DELETing keys' do
    let(:key) { 'imperium-tests/foo/bar' }
    let(:value) { 'baz' }
    let(:url) {
      Imperium.configuration.url.dup.tap {|url| url.path = "/v1/kv/#{key}" }
    }

    before do
      Net::HTTP.start(url.host, url.port) do |http|
        req = Net::HTTP::Put.new(url)
        req.body = value
        response = http.request(req)
        # If we didn't actually create the key we want to fail now
        expect(response).to be_a Net::HTTPOK
      end
    end

    after do
      # It's the only way to be sure
      Net::HTTP.start(url.host, url.port) do |http|
        http.request(Net::HTTP::Delete.new(url))
      end
    end

    it 'must do enough to clean up after tests' do
      delete_response = client.delete(key)
      get_response = Net::HTTP.get_response(url)
      expect(get_response).to be_a Net::HTTPNotFound
    end
  end
end
