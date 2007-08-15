module BytecodeConverter
  class << self
	  DATA_TYPE_CODES = {
	    :null     => '02',
	    :string   => '00',
	    :boolean  => '05',
	    :float    => '06',
	    :integer  => '07'
	  }    
	  NULL_TERMINATOR   = '00'

	  def convert(data=nil)
	    case data
			when Integer
				DATA_TYPE_CODES[:integer] + integer_to_bytecode(data, 4)
			when Float
				# '06DD9ABFBF5F633937'
				# pack the float into a little-endian binary sequence
				# ==================================
				# = Totally not working at all yet =
				# ==================================
				[*data].pack('E')
	    when String
	      DATA_TYPE_CODES[:string] + string_to_bytecode(data) + NULL_TERMINATOR
	    when Array
	      '961400070300000007020000000701000000070300000042'
	    when TrueClass
	      '0501'
	    when FalseClass
	      '0500'
	    when NilClass
	      '02'
	    else
	      raise StandardError, "#{data.class} is an unhandled data type"
	    end
	  end
 
	  protected
	  def string_to_bytecode(string)
	     string.unpack('H*').to_s.upcase
	  end
	
		def integer_to_bytecode(integer, num_bytes=1)
			# convert string to uppercase hex
 			hex = ('%X' % integer)
			
			# ensure that string is padded to the byte-boundary
			hex = '0' + hex if hex.length % 2 == 1

			# split into an array of hex pairs
  							     	# capturing parens in the regexp keep the letter-pairs used to split
								      # i.e. "aabbcc" becomes ["", "aa", "", "bb", "", "cc"]
			hex = hex.split(/(\w\w)/)
			
			# delete the empty strings
			hex.delete("")
			
			# reverse the array and join back into a string
			hex = hex.reverse.join
			
			hex = hex.ljust(num_bytes*2, '0')
		end
	end
end


__END__
## show what endianess a machine is taken from http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/256730
require 'rbconfig'
include Config

x = 0xdeadbeef

endian_type = { 
    Array(x).pack("V*") => :little,
    Array(x).pack("N*") => :big
}

puts "#{CONFIG['arch']} is a #{endian_type[Array(x).pack("L*")]} endian machine"