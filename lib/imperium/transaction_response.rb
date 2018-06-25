module Imperium
  # A Response is a decorator around the
  # {http://www.rubydoc.info/gems/httpclient/HTTP/Message HTTP::Message} object
  # returned when a transaction is made.
  #
  # It exposes, through a convenient API, headers common to all interactions
  # with the Consul HTTP API
  class TransactionResponse < Response
    # Add Results as a KVPair to the response coerced body
    #
    # @return Imperium::KVPair
    def results
      coerced_body['Results'].map do |result|
        KVPair.new(result['KV']) if result['KV']
      end
    end

    # Add Errors to the response coerced body
    #
    # @return the error
    def errors
      coerced_body['Errors']
    end
  end
end
