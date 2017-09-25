require_relative 'response'

module Imperium
  # EventResponse is a wrapper for the raw HTTP::Message response from the API
  #
  # @note This class doesn't really make sense to be instantiated outside of
  #   {Events#fire}
  class EventFireResponse < Response
    def id
      parsed_body['ID']
    end
  end
end
