require 'imperium'

module Imperium
  # A collection of functions to build responses for use in tests needing mock
  # responses.
  module Testing
    class Client < Imperium::Client
      def initialize
      end
      public :hashify_options
    end
    private_constant :Client

    MockResponse = Struct.new(:content, :status, :headers)

    @client = Client.new
    def self.kv_get_response(body: '[]', status: 200, headers: {}, prefix: '', options: [])
      expanded_options = @client.hashify_options(options)
      string_body = if String === body
                      body
                    else
                      body.map { |obj|
                        obj['Value'] = Base64.encode64(obj['Value']) if obj['Value']
                        obj[:Value] = Base64.encode64(obj[:Value]) if obj[:Value]
                        obj
                      }.to_json
                    end

      response = MockResponse.new(string_body, status, headers)
      KVGETResponse.new(response, prefix: prefix, options: expanded_options)
    end

    def self.kv_not_found_response(headers: {}, options: [])
      kv_get_response(body: '', status: 404, headers: headers, options: options)
    end
  end
end
