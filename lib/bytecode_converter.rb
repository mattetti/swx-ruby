require 'core_extensions'
require 'helper_module'

class BytecodeConverter
	include HelperMethods
  class << self
	  NULL_TERMINATOR = '00'
	
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
	      DataTypeCodes::BOOLEAN + '00'
	    when TrueClass
	      DataTypeCodes::BOOLEAN + '01'
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
			
			# Keeps track of bytecode when recursing into nested data structures
			stack = []

			# Add the bytecode to initialize the data structure
			bytecode.push(if data.is_a?(Array) then ActionCodes::INIT_ARRAY elsif data.is_a?(Hash) then ActionCodes::INIT_OBJECT end)

			# Add the length of the data structure to the bytecode
			bytecode.push integer_to_bytecode(data.length)
			
			# Convert each element in the data structure to bytecode
			data.each do |element|
				
				# If we're iterating over a hash, then split the element's key/value
				if (data.is_a?(Hash))
					value = element[1]
					element = element[0]
				end

				# Create a push of the current bytecode, if
					 # recursing into a complex data structure
					 #									 # or
				if (element.is_a?(Array) || 
					    value.is_a?(Array) || 
						element.is_a?(Hash)  || # we're approaching the 65535 byte limit that can be stored in a single push.
						  value.is_a?(Hash)	 || calculate_bytecode_length(bytecode) > 65518)
						
					# If we haven't written any bytecode into the local
					# buffer yet (if it's empty), or all the data is already pushed, skip writing the push statement
					bytecode.push generate_push_statement(bytecode) unless bytecode.empty? || bytecode.last.begins_with?('96')
					
					# Store current instruction on the stack (SWF bytecode is stored in reverse, so we reverse it here)
					stack.push bytecode.reverse.join
					
					# Reset the bytecode
					bytecode = []
				end
				
				# value will only be populated if we're iterating over a hash
				bytecode.push convert(value) unless value.nil?
				
				# element will always contain a something (whether iterating over a hash or an array)
				bytecode.push convert(element)
			end

      # If we haven't written any bytecode into the local
			# buffer yet (if it's empty), or all the data is already pushed, skip writing the push statement
      bytecode.push generate_push_statement(bytecode) unless bytecode.empty? || bytecode.last.begins_with?('96')
			
			# Add the bytecode to the local stack variable (SWF bytecode is stored in reverse, so we reverse it here)
			stack.push bytecode.reverse.join
			
			# Join the stack array into a string and return it (SWF bytecode is stored in reverse, so we reverse it here)
			stack.reverse.join
		end
	
		def float_to_bytecode(float)
			binary = [float].pack('E')[0..-1]
			ascii_codes = []
			binary.each_character_with_index { |character, index| ascii_codes << binary[index] }
			hex_codes = []
			ascii_codes.each { |ascii_code| hex_codes << '%02X' % ascii_code }
																# Aral did this in SWX PHP, so I'm doing it here
			DataTypeCodes::FLOAT + (hex_codes[4..-1] + hex_codes[0..3]).join
		end
	
		def integer_to_bytecode(integer)
			DataTypeCodes::INTEGER + integer_to_hexadecimal(integer, 4)
		end
				
		def string_to_bytecode(string)
	    DataTypeCodes::STRING + string.unpack('H*').to_s.upcase + NULL_TERMINATOR
	  end
	end
end