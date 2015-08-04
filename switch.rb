
puts "Carico gestore switch..."

def start_switch(mycfg)

	puts "Avvio switch con configurazione #{mycfg}"

	captures = Hash.new	
	macs = Hash.new

	puts "Avvio catture"
	mycfg['interfaces'].each do |iface|
		puts iface
		captures[iface] = PCAPRUB::Pcap.open_live(iface, 65535, true, 0)
		macs[iface] = Array.new
	end
	puts "Catture pronte: #{captures}"
	puts "Liste mac predisposte: #{macs}"

	## ciclo infinito qua?
	while 1==1

		captures.keys.each do |cap|
			#puts cap
			pkg = captures[cap].next()
			if pkg
				eth_pkg = PacketFu::Packet.parse pkg
				puts "Pacchetto di classe #{eth_pkg.class}"
				pclass = eth_pkg.class
				if pclass == PacketFu::InvalidPacket
					puts "Pacchetto non valido!?"
				else
					src = eth_pkg.eth_saddr
					dst = eth_pkg.eth_daddr
					puts "Letto pacchetto ETH su interfaccia #{cap} con src #{src} e dst #{dst}"

					#TODO: serve una scadenza oppure uno spostamento da una porta all'altra.
					if !macs[cap].include? src
						puts "Scoperto nuovo mac sull'interfaccia #{cap}"
						macs[cap].push src
					end

					founddstmac = false
					captures.keys.each do |scap|
						if !founddstmac && (macs[scap].include? dst)
							founddstmac = true
							puts "Mac trovato. Invio solo su interfaccia #{scap}"
							puts "#{macs}"
							eth_pkg.to_w(scap)
						end
					end

					if !founddstmac
						puts "Mac non trovato, invio a tutti..."
						captures.keys.each do |scap|
							if scap != cap
								puts "Invio pacchetto da #{cap} a #{scap}"
								eth_pkg.to_w(scap)
							end
						end
					end
				end
			end
		end
		#next1 = capture1.next()
		#if next1
		#eth_pkg = PacketFu::Packet.parse next1
		#eth_pkg.to_w("eth2")
		#	end

	end

end