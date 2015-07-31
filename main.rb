require 'rubygems'
require 'pcaprub'
require 'yaml'
require 'socket'
require 'packetfu'


def read_config
	config = YAML.load_file("config.yml")
	@bridge = config["config"]["bridge"]
end

read_config()

puts "Trovato bridge: #{@bridge}\n"


capture1 = PCAPRUB::Pcap.open_live('eth1', 65535, true, 0)
capture2 = PCAPRUB::Pcap.open_live('eth2', 65535, true, 0)
while 1==1
	next1 = capture1.next()
	if next1
		#puts "Arrivato pacchetto su eth1"
		eth_pkg = PacketFu::Packet.parse next1
		eth_pkg.to_w("eth2")
	end

	next2 = capture2.next()
	if next2
		#puts "Arrivato pacchetto su eth2"
		eth_pkg = PacketFu::Packet.parse next2
		eth_pkg.to_w("eth1")
	end

	#puts(capture1.stats())
	#puts(capture2.stats())
end

