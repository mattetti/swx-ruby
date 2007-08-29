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
		
		# Various contants
		COMPLEX_DATA_STRUCTURES = [Array, Hash]

	  def convert(data)
	    case data
	    when *COMPLEX_DATA_STRUCTURES
				complex_data_structure_to_bytecode(data)
			when Float
				float_to_bytecode(data)
			when Integer
				integer_to_bytecode(data)
	    when String
	      string_to_bytecode(data)
	    when FalseClass
	      DATA_TYPE_CODES[:boolean] + '00'
	    when TrueClass
	      DATA_TYPE_CODES[:boolean] + '01'
	    when NilClass
	      '02'
	    else
	      raise StandardError, "#{data.class} is an unhandled data type."
	    end
	  end
	

 
	  protected
		# ================================
		# = Data Type Conversion Methods =
		# ================================
		
		def complex_data_structure_to_bytecode(data)
			bytecode = []
			# keeps track of bytecode when recursing into nested data structures
			stack = []
			
			# Add the bytecode to initialize the data structure
			bytecode.unshift(data.is_a?(Array) ? ACTION_INIT_ARRAY : ACTION_INIT_OBJECT)

			# Add the length of the data structure to the bytecode
			bytecode.unshift integer_to_bytecode(data.length)
			
			# Convert each element in the array to bytecode
			data.each do |element|
				
				# If we're iterating over a Hash, then split the element's key/value
				if (data.is_a?(Hash))
					value = element[1]
					element = element[0]
				end

					# Recursing into a complex data structure
					#									   # OR
				if (element.is_a?(Array) || 
					  element.is_a?(Hash)	 || # We're close to the 65K limit that can be stored in a single push,
						value.is_a?(Array)   || # so create the push and reset the bytecode 
						value.is_a?(Hash)	   || calculate_bytecode_length(bytecode) > 65518)
						
					# Create a push of the current bytecode
						
					# If we haven't written any bytecode into the local
					# buffer yet (if it's empty),or all the data is already pushed, don't write a push statement.
					bytecode.unshift generate_push_statement(bytecode) unless bytecode.empty? || bytecode.first[0..1] == '96'
					
					# Store current instruction on the stack
					stack.unshift bytecode.join
					
					# Reset the bytecode
					bytecode = []
				end
				
				# value will only be populated if we're iterating over a Hash
				bytecode.unshift convert(value) unless value.nil?
				
				bytecode.unshift convert(element)
			end
			
			# If the bytecode string doesn't already begin with a push,
			# then add one that encompasses all of the unpushed data
			unless (bytecode.first[0..1] == '96')
				# Add a push statement for the unpushed data
				bytecode.unshift generate_push_statement(bytecode)
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
			ascii_codes.each { |ascii_code| hex_codes << '%02X' % ascii_code }
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
			unpushed_data = []
			# Iterate over the bytecode array and add all of the unpushed
			# data to 'unpushed_data'
			bytecode.each do |bytecode_chunk|
				if bytecode_chunk[0..1] == '96' then break else unpushed_data << bytecode_chunk end
			end
			
			bytecode_length = calculate_bytecode_length(unpushed_data)
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
			# split into an array of string pairs
			# reverse the array and join back into a string
			pad_string_to_byte_boundary(hex_string).scan(/(..)/).reverse.join
		end
		
		def pad_string_to_byte_boundary(hex_string)
			hex_string += '0' if hex_string.length % 2 == 1
			hex_string
		end
	end
end

class String
  def each_character_with_index
    split(//).each_with_index { |c, index|
      yield( c, index )
    }
  end
end