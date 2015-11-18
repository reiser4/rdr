



require 'mysql'



class Switch < L2

  def initialize(cfg)
  	super(cfg)
	@printdebug = true

	#todo: spostare in file apposito
	@con = Mysql.new 'localhost', 'root', 'enrico', 'rdr'

	cputs "Mysql avviato: #{@con}"
    cputs "#{@pfx}Configurazione per Switch: #{cfg}"

	@captures = Hash.new	
	# rimpiazzato da mysql
	#@macs = Hash.new

	cputs "#{@pfx}Avvio catture"
	cfg['interfaces'].each do |iface|
		cputs iface
		@captures[iface] = PCAPRUB::Pcap.open_live(iface, 65535, true, 0)
		#rimpiazzato da mysql
		#@macs[iface] = Array.new
	end
	cputs "#{@pfx}Catture pronte: #{@captures}"
	    
	@mymac = "22:22:22:33:33:33"    
	cputs "#{@pfx}Mio mac: #{@mymac}"
  end
  def readPacket(layers2)
    
		@captures.keys.each do |cap|
			#cputs cap
			pkg = @captures[cap].next()
			if pkg
				eth_pkg = PacketFu::Packet.parse pkg
				cputs "#{@pfx}Pacchetto di classe #{eth_pkg.class}"
				pclass = eth_pkg.class
				if pclass == PacketFu::InvalidPacket
					cputs "#{@pfx}Pacchetto non valido!?"
				else
					src = eth_pkg.eth_saddr
					dst = eth_pkg.eth_daddr
					cputs "#{@pfx}Letto pacchetto ETH su interfaccia #{cap} con src #{src} e dst #{dst}"

					#TODO: serve una scadenza oppure uno spostamento da una porta all'altra.
					if !mysqlFindMac(src)
						cputs "#{@pfx}Scoperto nuovo mac sull'interfaccia #{cap}"
						mysqlAddMac(src, cap)
						#@macs[cap].push src
					end

					self.sendPacket(eth_pkg, layers2, cap)
					
					dst = eth_pkg.eth_daddr
					cputs "Pacchetto per #{dst}, miomac: #{@mac}"
					return eth_pkg if dst == @mac
					return eth_pkg if dst == "ff:ff:ff:ff:ff:ff"
					cputs "Pacchetto non per me: non passo al layer 3"
				end
			end
		end

	return nil 

  end

	def sendPacket(eth_pkg, layers2, cap = nil) #invia un pacchetto di tipo PacketFu::Packet alla porta dove ho il mac.

		dst = eth_pkg.eth_daddr

		#founddstmac = false
		#@captures.keys.each do |scap|
		#	if !founddstmac && (@macs[scap].include? dst)
		#		founddstmac = true
		#		cputs "#{@pfx}Mac trovato. Invio solo su interfaccia #{scap}"
		#		cputs "#{@pfx}#{@macs}"
		#		eth_pkg.to_w(scap)
		#	end
		#end

		dstmacif = mysqlFindMac(dst)

		if !dstmacif
			cputs "#{@pfx}Mac non trovato, invio a tutti..."
			@captures.keys.each do |scap|
				if scap != cap
					cputs "#{@pfx}Invio pacchetto da #{cap} a #{scap}"
					eth_pkg.to_w(scap)
				end
			end
		else
			cputs "Mac trovato!! #{dstmacif}"
			scap = dstmacif[3]
			eth_pkg.to_w(scap)
		end

  end


  def mysqlFindMac(mac)
  	#todo: implementare rimozione voci vecchie

  	rs = @con.query("SELECT * FROM `switchosts` WHERE `mac` = '#{mac}';")
  	n_rows = rs.num_rows
  	if n_rows == 0
  		return false
  	end

  	res = rs.fetch_row

  	now = Time.now.to_i
  	age = res[4].to_i
  	id = res[0]

  	if (now-age) > 30
  		#troppo vecchio: elimino
  		dq = @con.query("DELETE FROM `switchosts` WHERE `id`='#{id}';")
  		return false
  	end

  	puts "#{res}"

  	uq = @con.query("UPDATE `switchosts` SET `timeout`='#{now}' WHERE `id`='#{id}';")

  	return res
  	#todo: se trovato: rinfresco



  	#@con.query

  end

  def mysqlAddMac(mac, port)
  	bridge = @name
  	now = Time.now.to_i
  	@con.query("INSERT INTO `switchosts` (`switch`, `mac`, `port`, `timeout`) VALUES ('#{bridge}', '#{mac}', '#{port}', '#{now}');")
  end


end
