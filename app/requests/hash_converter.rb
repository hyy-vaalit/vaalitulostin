# Net::Http requires nested parameters to be experessed as
# nested[param] = value. This means that ActionController params
# in format { nested: { param: value }} do not work.
#
# Kudos to: http://dev.mensfeld.pl/2012/01/converting-nested-hash-into-http-url-params-hash-version-in-ruby/
module HashConverter

  def self.encode(value, key = nil, out_hash = {})
    case value
    when Hash, ActionController::Parameters  then
      value.each { |k,v| encode(v, append_key(key,k), out_hash) }
      out_hash
    when Array then
      value.each { |v| encode(v, "#{key}[]", out_hash) }
      out_hash
    when nil   then ''
    else
      out_hash[key] = value
      out_hash
    end
  end

  private

  def self.append_key(root_key, key)
    root_key.nil? ? :"#{key}" : :"#{root_key}[#{key.to_s}]"
  end

end
