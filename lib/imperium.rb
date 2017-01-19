require 'imperium/configuration'
require 'imperium/version'

module Imperium
  def self.configure
    yield configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end
end
