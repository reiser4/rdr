

puts "Carico supporto a GRE"

require_relative 'arp'


def start_gre(config)
	puts "Avvio GRE: #{config}"

	## apro socket in ascolto per pacchetti gre
	iface = config['if']
	puts "Ascolto su #{iface}"

	capture = PCAPRUB::Pcap.open_live(iface, 65535, true, 0)
	while 1==1

		pkg = capture.next()
		if pkg
			eth_pkg = PacketFu::Packet.parse pkg
			puts "Ricevuto pacchetto #{eth_pkg.class}"
		end
	end

	puts "Fine"
end