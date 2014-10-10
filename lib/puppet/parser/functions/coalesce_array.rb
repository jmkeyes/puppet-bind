module Puppet::Parser::Functions
  newfunction(:coalesce_array, :type => :rvalue) do |arguments|
    collection, sentinel = arguments[0], arguments[1]

    unless arguments.size >= 1
      raise Puppet::ParseError, "coalesce_array(): Wrong number of arguments; expected at least 1, got #{arguments.size}!"
    end

    unless collection.kind_of?(Array)
      raise Puppet::ParseError, "coalesce_array(): Invalid arguments; collection must be an array!"
    end

    return '/* nil */' if collection.empty? and sentinel.nil?
      
    (collection.length > 0 ? collection.join('; ') : sentinel) + ';'
  end
end
