

class Eth

  def initialize(cfg)
  	@pfx = "[ETH] "
  	@printdebug = false

    cputs "#{@pfx}Configurazione per ETH: #{cfg}"
	cputs "#{@pfx}Avvio cattura"
	iface = cfg['dev']
	@capture = PCAPRUB::Pcap.open_live(iface, 65535, true, 0)
	cputs "#{@pfx}Cattura pronta: #{@captures}"

	@mymac = "00:01:02:02:02:02"
	cputs "#{@pfx}Mio mac: #{@mymac}"

  end
  def readPacket
    pkg = @capture.next()
	if pkg
		cputs "#{@pfx}Ricevuto pacchetto su ETH!"
		eth_pkg = PacketFu::Packet.parse pkg
		if eth_pkg.class == PacketFu::InvalidPacket
			cputs "#{@pfx}Pacchetto non valido, non lo passo al layer 3"
			return nil
		end
		dst = eth_pkg.eth_daddr
		cputs "#{@pfx}Pacchetto per #{dst}"
		return eth_pkg if dst == @mymac
		return eth_pkg if dst == "ff:ff:ff:ff:ff:ff"
		cputs "#{@pfx}Pacchetto non per me: non passo al layer 3"
		return nil
	end
  end
  def cputs(text)
    puts "#{text}" if @printdebug
  end
end
