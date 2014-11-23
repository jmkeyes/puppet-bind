require 'base64'
require 'openssl'

module Puppet::Parser::Functions
  newfunction(:digest_random, :type => :rvalue, :arity => 1) do |arguments|
    algorithm = arguments[0] || 'md5'

    # Open the requested digest algorithm.
    digest = OpenSSL::Digest.new(algorithm)

    # Find the digest length of the given algorithm and collect as many random bytes.
    data = OpenSSL::Random.random_bytes(digest.digest_length)

    # Encode the output in Base64, trimming excess whitespace.
    Base64.encode64(data).tr("\n", ' ').strip
  end
end
