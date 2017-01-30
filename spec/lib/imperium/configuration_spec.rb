require 'spec_helper'

RSpec.describe Imperium::Configuration do
  let(:config) {
    Imperium::Configuration.new(url: 'http://consul.example.com:8500', token: 'sekret')
  }

  describe "#initialize(url: '', token: nil)" do
    it 'must default the url to a sensible value' do
      local_config = Imperium::Configuration.new
      expect(local_config.url).to eq Addressable::URI.parse('http://localhost:8500')
    end

    it 'must default the token to nil' do
      local_config = Imperium::Configuration.new
      expect(local_config.token).to be_nil
    end

    it 'must capure the supplied url and parse it' do
      local_config = Imperium::Configuration.new(url: 'https://consul.example.com:8500')
      expect(local_config.url).to eq Addressable::URI.parse('https://consul.example.com:8500')
    end

    it 'must capture the supplied token' do
      local_config = Imperium::Configuration.new(token: 'sekret')
      expect(local_config.token).to eq 'sekret'
    end
  end

  it 'must delegate the host getter to the URL' do
    expect(config.host).to eq 'consul.example.com'
  end

  it 'must delegate the host setter to the URL' do
    config.host = 'consul.foobar.example.com'
    expect(config.url.host).to eq 'consul.foobar.example.com'
  end

  it 'must delegate the port getter to the URL' do
    expect(config.port).to eq 8500
  end

  it 'must delegate the port setter to the URL' do
    config.port = 1234
    expect(config.url.port).to eq 1234
  end

  describe '#token?' do
    it 'must return false when the token is an empty string' do
      config.token = ''
      expect(config).to_not be_token
    end

    it 'must return false when the token is nil' do
      config.token = nil
      expect(config).to_not be_token
    end

    it 'must return true when a token is set' do
      config.token = 'super-sekret-token'
      expect(config).to be_token
    end
  end

  describe '#url=(value)' do
    it 'must nil out the URL when passed nil' do
      config.url = nil
      expect(config.url).to be_nil
    end

    it 'must parse a string URL' do
      config.url= 'https://foo.example.com'
      expect(config.url).to eq Addressable::URI.parse('https://foo.example.com')
    end

    it 'must simply capture an already parsed URL' do
      config.url = Addressable::URI.parse('https://example.com')
      expect(config.url).to eq Addressable::URI.parse('https://example.com')
    end

    it 'must reparse a URL parsed by the stdlib parser' do
      config.url = URI.parse('https://foo.example.com')
      expect(config.url).to be_a Addressable::URI
      expect(config.url).to eq Addressable::URI.parse('https://foo.example.com')
    end

    it 'must append a trailing slash when there is not one on the path component' do
      config.url = 'http://consul.example.com/namespace'
      expect(config.url.path).to eq '/namespace/'
    end

    it 'must not append a trailing slash when there is already one present on the path component' do
      config.url = 'http://consul.example.com/namespace/'
      expect(config.url.path).to eq '/namespace/'
    end
  end

  describe '#ssl?' do
    it 'must return false when the url has http' do
      config.url = 'http://example.com'
      expect(config).to_not be_ssl
    end

    it 'must return true when the url has https' do
      config.url = 'https://example.com'
      expect(config).to be_ssl
    end
  end

  describe '#ssl=' do
    it 'must set the scheme to https when true is passed' do
      config.url = 'http://example.com'
      config.ssl = true
      expect(config.url.scheme).to eq 'https'
    end

    it 'must set the scheme to http when false is passed' do
      config.url = 'https://example.com'
      config.ssl = false
      expect(config.url.scheme).to eq 'http'
    end
  end
end
