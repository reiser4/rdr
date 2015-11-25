



class L2

	def initialize(cfg)
		@printdebug = true
		@ipv4 = Array.new
		@ipv4.push(cfg['ipv4'])
		@mac = "00:01:02:03:04:05"
		@name = cfg['name']
		@rrdtime = 0
	end

	def createRRD(iface)
		if File.exist?("../rdr-rails/rrd/" + iface + ".rrd")
			cputs "Database RRD trovato: " + iface
		else
			cputs "Creo database RRD per "+iface
			cmd = "cd ../rdr-rails/rrd && rrdtool create "+iface+".rrd -s 60 DS:tx:COUNTER:300:0:U DS:rx:COUNTER:300:0:U RRA:AVERAGE:0.5:1:250"
			cputs cmd
			system(cmd)
		end
	end


	def saveRRD()
		if (Time.now.to_i - @rrdtime) > 1 * 60
			@rrdtime = Time.now.to_i
			cputs "Salvo dati RRD..."
			@stats.keys.each do |iface|
				cmd = "cd ../rdr-rails/rrd && rrdtool update " + iface + ".rrd N:"+
					((@stats[iface]["tx"] * 8).to_s) +":"+
					((@stats[iface]["rx"] * 8).to_s)
				cputs cmd
				cputs system(cmd)
			end
		end
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