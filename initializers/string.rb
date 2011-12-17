class String #:nodoc:
    
  # ====================
  # = Instance Methods =
  # ====================
  def split_by_any(*args)
    string = self
    array = string.split(args.first)
    args.to_a.each do |splitter|
      array = array.map{|item| item.split(splitter)}.flatten
    end
    return array.reject{|item| item.blank?}
  end
  
  def email?
    self.match(Regex.email)
  end
  
  def phone?
    self.gsub(/[ -\.\)\(]/, '').gsub(/^1/, '').match(/^\d{10}$/)
  end
  
  # =========
  # = Regex =
  # =========
  class Regex
    def self.email
      /^.+@.+\.[a-z]+$/
    end
    
    def self.login
      /^[a-zA-Z0-9\-_]+$/
    end
    
    def self.zip_code
      /^\d{5}$/
    end
  end
  
end