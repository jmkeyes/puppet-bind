require 'base64'
require 'openssl'

module Puppet::Parser::Functions
  newfunction(:hmac, :type => :rvalue) do |arguments|
    unless arguments.size == 3
      raise Puppet::ParseError, "hmac(): Wrong number of arguments; expected 3, got #{arguments.size}!"
    end

    # Open the requested digest algorithm and compute an HMAC with it.
    digest = OpenSSL::Digest::Digest.new(arguments[0])
    value  = OpenSSL::HMAC.digest(digest, arguments[1], arguments[2])

    # Encode the output in Base64.
    Base64.encode64(value).chomp
  end
end
