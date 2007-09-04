
# ===================
# = Core Extensions =
# ===================
class String
  def begins_with?(string)
    self[0..string.length-1] == string
  end
  
	def each_character_with_index
    split(//).each_with_index { |c, index|
      yield( c, index )
    }
  end
	
	def hex_to_ascii
		hex = self.gsub(' ', '')
		[hex].pack('H*')
	end
end

class Array
  def begins_with?(string)
    self.join.begins_with?(string)
  end  
end