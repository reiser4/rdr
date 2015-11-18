

class Hub

  def initialize(cfg)

    puts "Configurazione per Hub: #{cfg}"

    @captures = Hash.new	
	
	puts "Avvio catture"
	cfg['interfaces'].each do |iface|
		puts iface
		@captures[iface] = PCAPRUB::Pcap.open_live(iface, 65535, true, 0)
	end
	puts "Catture pronte: #{@captures}"



  end
  def readPacket(l2)
    #puts "Leggo pacchetti dall'hub"
    @captures.keys.each do |cap|
		#puts cap
		pkg = @captures[cap].next()
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
				@captures.keys.each do |scap|
					if scap != cap
						puts "Invio pacchetto da #{cap} a #{scap}"
						eth_pkg.to_w(scap)
					end
				end
			end
		end
	end

	nil #todo: restituire pacchetto se per me...

  end

end
