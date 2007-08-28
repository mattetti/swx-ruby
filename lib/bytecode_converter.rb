class String
  def each_character_with_index
    split(//).each_with_index { |c, index|
      yield( c, index )
    }
  end
end


module BytecodeConverter
  class << self
	  DATA_TYPE_CODES = {
	    :null     => '02',
	    :string   => '00',
	    :boolean  => '05',
	    :float    => '06',
	    :integer  => '07'
	  }    
	  NULL_TERMINATOR = '00'
	
		# Action bytecodes
		ACTION_INIT_ARRAY  = '42'
		ACTION_INIT_OBJECT = '43'
		

	  def convert(data=nil)
	    case data
			when Integer
				integer_to_bytecode(data)
			when Float
				float_to_bytecode(data)
	    when String
	      string_to_bytecode(data)
	    when Array
				array_to_bytecode(data)
	    when TrueClass
	      DATA_TYPE_CODES[:boolean] + '01'
	    when FalseClass
	      DATA_TYPE_CODES[:boolean] + '00'
	    when NilClass
	      '02'
	    else
	      raise StandardError, "#{data.class} is an unhandled data type"
	    end
	  end
	

 
	  protected
		# ================================
		# = Data Type Conversion Methods =
		# ================================
		def array_to_bytecode(array)
			bytecode = []
			# keeps track of bytecode when recursing into nested arrays
			stack = []
			
			# Add the length of the array to the bytecode
			bytecode << integer_to_bytecode(array.length)
			
			# Add the bytecode to initialize the array
			bytecode << ACTION_INIT_ARRAY
			
			# Convert each element in the array to bytecode
			array.each do |element|

				if (element.is_a?(Array))
					# If we haven't written any bytecode into the local
					# buffer yet (if it's empty), don't write a push statement.
					bytecode.unshift generate_push_statement(bytecode) unless bytecode.empty?
					
					# Store current instruction on the stack
					stack.unshift bytecode.join
					
					# Reset the bytecode
					bytecode = []
				end
				
				bytecode.unshift convert(element)
				
			end
			
			# If the bytecode string doesn't already begin with a push,
			# then add one that encompasses all of the unpushed data
			unless (bytecode.first[0..1] == '96')
				# Init the array to hold the data that needs to be pushed
				push_data = []
				# Iterate over the bytecode array and add all of the unpushed
				# data to 'push_data'
				bytecode.each do |bytecode_chunk|
					if bytecode_chunk[0..1] == '96' then break else push_data << bytecode_chunk end
				end
				# Add a push statement for the unpushed data
				bytecode.unshift generate_push_statement(push_data)
			end
			
			# Add the bytecode to the local stack variable
			stack.unshift bytecode.join
			# Join the stack array into a string and return it
			stack.join
		end
	
		def float_to_bytecode(float)
			binary = [float].pack('E')
			ascii_codes = []
			binary.each_character_with_index { |character, index| ascii_codes << binary[index] }
			hex_codes = []
			ascii_codes.each { |ascii_code| hex_codes << sprintf('%02X', ascii_code) }
																# Aral did this in SWX PHP, so I'm doing it here
			DATA_TYPE_CODES[:float] + (hex_codes[4..-1] + hex_codes[0..3]).join
		end
	
		def integer_to_bytecode(integer)
			DATA_TYPE_CODES[:integer] + integer_to_hexadecimal(integer, 4)
		end
				
		def string_to_bytecode(string)
	     DATA_TYPE_CODES[:string] + string.unpack('H*').to_s.upcase + NULL_TERMINATOR
	  end
	
	
		# ==================
		# = Helper Methods =
		# ==================
		def generate_push_statement(bytecode)
			bytecode_length = calculate_bytecode_length(bytecode)
  		 # TODO: Replace with constant
			'96' + integer_to_hexadecimal(bytecode_length, 2)
		end
		
		def calculate_bytecode_length(bytecode)
			bytecode_length = bytecode.join.length/2
			
			# Calculate bytecode length *without* counting the 
			# init object or init array action
			bytecode_length -=1 if (bytecode.last == ACTION_INIT_ARRAY || bytecode.last == ACTION_INIT_OBJECT)
			
			bytecode_length
		end
		
		def integer_to_hexadecimal(integer, number_of_bytes=1)
			make_little_endian("%0#{number_of_bytes*2}X" % integer)
		end
		
		def make_little_endian(hex_string)
			hex_string = pad_string_to_byte_boundary(hex_string)
			
			# split into an array of hex pairs
  							     	# capturing parens in the regexp keep the letter-pairs used to split
								      # i.e. "aabbcc" becomes ["", "aa", "", "bb", "", "cc"]
			hex_string = hex_string.split(/(\w\w)/)
			
			# delete the empty strings
			hex_string.delete("")
			
			# reverse the array and join back into a string
			hex_string.reverse.join
		end
		
		def pad_string_to_byte_boundary(hex_string)
			hex_string = '0' + hex_string if hex_string.length % 2 == 1
			hex_string
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