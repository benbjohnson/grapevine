class Hash
  # Returns a new hash that has all string keys converted to symbols.
  def symbolize
    hash = {}
    
    each do |k, v|
      hash[k.to_sym] = v
    end
    
    return hash
  end
end