

class Eth < L2

  def initialize(cfg)
  	super(cfg)
  	@printdebug = true
    cputs "Configurazione per ETH: #{cfg}"
	cputs "Avvio cattura"
	@iface = cfg['dev']
	@capture = PCAPRUB::Pcap.open_live(@iface, 65535, true, 0)
	cputs "Cattura pronta: #{@captures}"

	createRRD(@iface)
	@stats = Hash.new
	@stats[@iface] = {"tx" => 0, "rx" => 0}
	@mac = "00:01:02:02:02:02"
	cputs "Mio mac: #{@mac}"

  end
  def readPacket(l2)
    pkg = @capture.next()
	if pkg
		@stats[@iface]["rx"] += pkg.size
		saveRRD()
		cputs "Ricevuto pacchetto su ETH!"
		eth_pkg = PacketFu::Packet.parse pkg
		if eth_pkg.class == PacketFu::InvalidPacket
			cputs "Pacchetto non valido, non lo passo al layer 3"
			return nil
		end
		dst = eth_pkg.eth_daddr
		cputs "Pacchetto per #{dst}, miomac: #{@mac}"
		return eth_pkg if dst == @mac
		return eth_pkg if dst == "ff:ff:ff:ff:ff:ff"
		cputs "Pacchetto non per me: non passo al layer 3"
		return nil
	end
  end

  def sendPacket(packet,layers2)
  	cputs "Pacchetto..."
  	#File.write('/var/www/html/pkt6', packet)
  	@stats[@iface]["tx"] += packet.size
  	saveRRD()
  	packet.to_w(@iface)
  end

end
