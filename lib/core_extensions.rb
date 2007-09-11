
# ===================
# = Core Extensions =
# ===================
class Array
  def begins_with?(string)
    self.join.begins_with?(string)
  end  
end

class Object
	# Taken from ActiveRecord
	def instance_values
    instance_variables.inject({}) do |values, name|
      values[name[1..-1]] = instance_variable_get(name)
      values
    end
  end
end

class String
  def begins_with?(string)
    self[0..string.length-1] == string
  end
  
	# Taken from Rails' Inflector module
	def constantize
	  unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ self
	    raise NameError, "#{self.inspect} is not a valid constant name!"
	  end
	
	  Object.module_eval("::#{$1}", __FILE__, __LINE__)
	end
	
	def hex_to_ascii
		hex = self.gsub(' ', '')
		[hex].pack('H*')
	end
	
	# Taken from Rails' Inflector module
	def underscore
	  self.to_s.gsub(/::/, '/').
	    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
	    gsub(/([a-z\d])([A-Z])/,'\1_\2').
	    tr("-", "_").
	    downcase
	end
end

