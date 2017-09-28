require 'spec_helper'

RSpec.describe Imperium::Service do
  let(:service) {
    Imperium::Service.new({
      "ID" => "redis1",
      "Name" => "redis",
      "Tags" => [
        "primary",
        "v1"
      ],
      "Address" => "127.0.0.1",
      "Port" => 8000,
      "EnableTagOverride" => false,
      "Check" => {
        "DeregisterCriticalServiceAfter" => "90m",
        "Script" => "/usr/local/bin/check_redis.py",
        "HTTP" => "http =>//localhost:5000/health",
        "Interval" => "10s",
        "TTL" => "15s"
      }
    })
  }

  describe '#initialize' do
    it 'must set the tags attribute to an empty array when left unset' do
      s = Imperium::Service.new
      expect(s.tags).to eq []
    end

    it 'must set the checks attribute to an empty array when left unset' do
      s = Imperium::Service.new
      expect(s.checks).to eq []
    end
  end

  describe '#tags=' do
    it 'must set the value to an empty array when nil is passed' do
      service.tags = nil
      expect(service.tags).to eq []
    end
  end

  describe '#add_check' do
    it 'must convert a supplied hash into a ServiceCheck object' do
      service.add_check({id: 'foobar'})
      expect(service.checks.last).to be_a Imperium::ServiceCheck
      expect(service.checks.last).to eq Imperium::ServiceCheck.new(id: 'foobar')
    end

    it 'must capture a ServiceCheck object' do
      check = Imperium::ServiceCheck.new(id: 'foobar')
      service.add_check(check)
      expect(service.checks.last).to eq check
    end
  end

  describe 'checks=' do
    it 'must set the value to an empty array when nil is passed' do
      service.checks = nil
      expect(service.checks).to eq []
    end

    it 'must convert an array of hashes to an array of ServiceCheck objects' do
      hashes = [{id: 'foo'}, {id: 'bar'}]
      service.checks = hashes
      expect(service.checks).to eq hashes.map { |h| Imperium::ServiceCheck.new(h) }
    end

    it 'must capture an array of ServiceCheck objects' do
      checks = [{id: 'foo'}, {id: 'bar'}].map { |h| Imperium::ServiceCheck.new(h) }
      service.checks = checks
      expect(service.checks).to eq checks
    end

    it 'must handle an array of mixed ServiceCheck objects and Hashes' do
      checks = [Imperium::ServiceCheck.new({id: 'foo'}), {id: 'bar'}]
      service.checks = checks
      expect(service.checks).to eq [Imperium::ServiceCheck.new({id: 'foo'}), Imperium::ServiceCheck.new({id: 'bar'})]
    end
  end


  describe '#registration_data' do
    let(:reg_data) { service.registration_data }

    it 'must include the Name attribute' do
      expect(reg_data).to include 'Name' => 'redis'
    end

    it 'must include the ID attribute if set' do
      expect(reg_data).to include 'ID' => 'redis1'
      service.id = nil
      expect(service.registration_data).to_not include 'ID'
    end

    it 'must include the Address attribute if set' do
      expect(reg_data).to include 'Address' => '127.0.0.1'
      service.address = nil
      expect(service.registration_data).to_not include 'Address'
    end

    it 'must include the Checks attribute if set' do
      service.checks << {}
      expect(service.registration_data).to include 'Checks'
    end

    it 'must include the EnableTagOverride attribute when set to true' do
      expect(reg_data).to_not include 'EnableTagOverride'
      service.enable_tag_override = true
      expect(service.registration_data).to include 'EnableTagOverride'
    end
  end
end
