

class Switch < L2

  def initialize(cfg)
  	super(cfg)
	@printdebug = false

    cputs "#{@pfx}Configurazione per Switch: #{cfg}"

	@captures = Hash.new	
	@macs = Hash.new

	cputs "#{@pfx}Avvio catture"
	cfg['interfaces'].each do |iface|
		cputs iface
		@captures[iface] = PCAPRUB::Pcap.open_live(iface, 65535, true, 0)
		@macs[iface] = Array.new
	end
	cputs "#{@pfx}Catture pronte: #{@captures}"
	    
	@mymac = "22:22:22:33:33:33"    
	cputs "#{@pfx}Mio mac: #{@mymac}"
  end
  def readPacket
    
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
					if !@macs[cap].include? src
						cputs "#{@pfx}Scoperto nuovo mac sull'interfaccia #{cap}"
						@macs[cap].push src
					end

					self.sendPacket(eth_pkg, cap)
					
				end
			end
		end

	nil ## todo: inviare verso il layer3 i pacchetti per me

  end

	def sendPacket(eth_pkg, cap = nil) #invia un pacchetto di tipo PacketFu::Packet alla porta dove ho il mac.

		dst = eth_pkg.eth_daddr

		founddstmac = false
		@captures.keys.each do |scap|
			if !founddstmac && (@macs[scap].include? dst)
				founddstmac = true
				cputs "#{@pfx}Mac trovato. Invio solo su interfaccia #{scap}"
				cputs "#{@pfx}#{@macs}"
				eth_pkg.to_w(scap)
			end
		end

		if !founddstmac
			cputs "#{@pfx}Mac non trovato, invio a tutti..."
			@captures.keys.each do |scap|
				if scap != cap
					cputs "#{@pfx}Invio pacchetto da #{cap} a #{scap}"
					eth_pkg.to_w(scap)
				end
			end
		end

  end

end
