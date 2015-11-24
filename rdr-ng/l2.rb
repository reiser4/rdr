



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
			cmd = "cd ../rdr-rails/rrd && rrdtool create "+iface+".rrd --start 1448381001 DS:tx:COUNTER:600:U:U DS:rx:COUNTER:600:U:U RRA:AVERAGE:0.5:1:10"
			cputs cmd
			system(cmd)
		end

	end


	def saveRRD()

		#cputs "Verifico se devo salvare i dati RRD -----------------------------------"
		if (Time.now.to_i - @rrdtime) > 5 * 60
			@rrdtime = Time.now.to_i
			cputs "Salvo dati RRD..."

			@stats.keys.each do |iface|
				cputs iface
				cputs @stats[iface]["tx"]
				cputs @stats[iface]["rx"]
				cmd = "cd ../rdr-rails/rrd && rrdtool update " + iface + ".rrd N:"+@stats[iface]["tx"].to_s+":"+@stats[iface]["rx"].to_s
				cputs cmd
				system(cmd)
			end
			#cputs "Rx e Tx: " + @stats[iface]
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