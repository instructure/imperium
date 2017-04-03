
module Imperium
  class Error < StandardError; end

  class InvalidConsistencySpecification < Error; end

  # Generic Network timeout error
  class TimeoutError < Error; end

  # Raised when opening the TCP socket times out
  class ConnectTimeout < TimeoutError; end

  # Raised when sending the request body took too long
  class SendTimeout < TimeoutError; end

  # Raised when the remote server took too long to respond.
  class ReceiveTimeout < TimeoutError; end

  # Raised when we can't open a socket to the specified consul server
  class UnableToConnectError < SocketError; end
end
