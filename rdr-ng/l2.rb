



class L2

	def initialize(cfg)
		@printdebug = true
		@ipv4 = Array.new
		@ipv4.push(cfg['ipv4'])
		@mac = "00:01:02:03:04:05"
		@name = cfg['name']
	end


	def cputs(text)
		puts "[L2][#{self.class}] #{text}" if @printdebug == true
	end

	def name()
		return @name
	end

	def ipv4()
		#todo: migliorare questo ack (usato da arp request)
		@ipv4.each do |v4|
			addr = v4.split("/")[0]
          	return addr
		end
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

 	def sendPacket(packet,layers2)
 		cputs "sendPacket non implementato!!"
 	end
end