



class L2

	def initialize(cfg)
		@printdebug = true
		@ipv4 = Array.new
		@ipv4.push(cfg['ipv4'])
		@mac = "00:01:02:03:04:05"
	end


	def cputs(text)
		puts "[L2][#{self.class}] #{text}" if @printdebug == true
	end

	def has_ip?(ip)
		cputs "V4: #{@ipv4}"
    	@ipv4.each do |v4|
        	addr = v4.split("/")[0]
          	return true if addr == ip
      	end
    	return false
 	end

 	def mac()
 		return @mac
 	end

 	def sendPacket(packet)
 		cputs "sendPacket non implementato!!"
 	end
end