require_relative 'api_object'
module Imperium
  # ServiceCheck is a container for data being received from and sent to the
  # agent services and checks apis.
  #
  # @see https://www.consul.io/api/agent/check.html Agent Checks API documentation
  #
  # @!attribute [rw] id
  #   @return [String] The service's id, when creating a new check this will
  #     be automatically assigned if not supplied, must be unique.
  # @!attribute [rw] name
  #   @return [String] The check's name in the consul UI, required for
  #     creation, not required to be unique.
  # @!attribute [rw] script (deprecated since consul 1.0)
  #   @return [String] Specifies a script or path to a script to run on Interval
  #     to update the status of the check. If specifying a path, this path must
  #     exist on disk and be readable by the Consul agent.
  # @!attribute [rw] args
  #   @return [Array<String>] Specifies command arguments to run to update the
  #     status of the check. Prior to Consul 1.0, checks used a single Script
  #     field to define the command to run, and would always run in a shell.
  #     In Consul 1.0, the Args array was added so that checks can be run
  #     without a shell. The Script field is deprecated, and you should
  #     include the shell in the Args to run under a shell,
  #     eg. "args": ["sh", "-c", "..."].
  # @!attribute [rw] docker_container_id
  #   @return [String] Specifies that the check is a Docker check, and Consul
  #     will evaluate the script every Interval in the given container using the
  #     specified Shell. Note that Shell is currently only supported for Docker checks.
  # @!attribute [rw] shell
  #   @return [String] The shell to use for docker checks, only applies when
  #     docker_container_id is specified
  # @!attribute [rw] interval
  #   @return [String] Specifies the frequency at which to run this check. This
  #     is required for HTTP and TCP checks.
  # @!attribute [rw] timeout
  #   @return [String]
  # @!attribute [rw] ttl
  #   @return [String] Specifies this is a TTL check, and the TTL endpoint must
  #     be used periodically to update the state of the check.
  # @!attribute [rw] http
  #   @return [String] Specifies an HTTP check to perform a GET request against
  #     the value of HTTP (expected to be a URL) every Interval. If the response
  #     is any 2xx code, the check is passing. If the response is 429 Too Many
  #     Requests, the check is warning. Otherwise, the check is critical. HTTP
  #     checks also support SSL. By default, a valid SSL certificate is
  #     expected. Certificate verification can be controlled using the
  #     TLSSkipVerify.
  # @!attribute [rw] headers
  #   @return [Hash<String => String>] Specifies a set of headers that should be
  #     set for HTTP checks. Each header can have multiple values.
  # @!attribute [rw] method
  #   @return [String] Specifies a different HTTP method to be used for an HTTP
  #     check. When no value is specified, GET is used.
  # @!attribute [rw] tcp
  #   @return [String] Specifies a TCP to connect against the value of TCP
  #     (expected to be an IP or hostname plus port combination) every Interval.
  #     If the connection attempt is successful, the check is passing. If the
  #     connection attempt is unsuccessful, the check is critical. In the case
  #     of a hostname that resolves to both IPv4 and IPv6 addresses, an attempt
  #     will be made to both addresses, and the first successful connection
  #     attempt will result in a successful check.
  # @!attribute [rw] status
  #   @return [String] Specifies the initial status of the health check.
  # @!attribute [rw] notes
  #   @return [String] Specifies arbitrary information for humans. This is not
  #     used by Consul internally.
  # @!attribute [rw] tls_skip_verify
  #   @return [String] Specifies if the certificate for an HTTPS check should
  #     not be verified.
  # @!attribute [rw] deregister_critical_service_after
  #   @return [String] Specifies that checks associated with a service should
  #     deregister after this time. This is specified as a time duration with
  #     suffix like "10m". If a check is in the critical state for more than
  #     this configured value, then its associated service (and all of its
  #     associated checks) will automatically be deregistered. The minimum
  #     timeout is 1 minute, and the process that reaps critical services runs
  #     every 30 seconds, so it may take slightly longer than the configured
  #     timeout to trigger the deregistration. This should generally be
  #     configured with a timeout that's much, much longer than any expected
  #     recoverable outage for the given service.
  # @!attribute [rw] service_id
  #   @return [String] Specifies the ID of a service to associate the
  #     registered check with an existing service provided by the agent. Does
  #     not need to be set when registering the check at the same time as
  #     registering a service
  class ServiceCheck < APIObject
    self.attribute_map = {
      'ID' => :id,
      'Name' => :name,
      'Script' => :script,
      'Args' => :args,
      'DockerContainerID' => :docker_container_id,
      'Shell' => :shell,
      'Interval' => :interval,
      'Timeout' => :timeout,
      'TTL' => :ttl,
      'HTTP' => :http,
      'Header' => :headers,
      'Method' => :method,
      'TCP' => :tcp,
      'Status' => :status,
      'Notes' => :notes,
      'TLSSkipVerify' => :tls_skip_verify,
      'DeregisterCriticalServiceAfter' => :deregister_critical_service_after,
      'ServiceID' => :service_id,
    }
  end
end
