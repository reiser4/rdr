require 'rubygems'
require 'pcaprub'
require 'yaml'
require 'socket'
require 'packetfu'


def read_config
	config = YAML.load_file("config.yml")
	##@bridge = config["config"]["bridge"]
	puts "Letta configurazione: #{config}"
	puts "Entro in config"
	puts " - #{config['config']}"
	cfg = config['config']
	cfg.keys.each do |type|
		puts "Trovata interfaccia di tipo #{type}"
		puts "Configurazione: #{cfg[type]}"
		thisconf = cfg[type]
		require_relative type
		send("start_#{type}",thisconf)
		#require "#{type}"

	end
end

read_config()



puts "Trovato bridge: #{@bridge}\n"


capture2 = PCAPRUB::Pcap.open_live('eth2', 65535, true, 0)
while 1==1

	next2 = capture2.next()
	if next2
		#puts "Arrivato pacchetto su eth2"
		eth_pkg = PacketFu::Packet.parse next2
		eth_pkg.to_w("eth1")
	end

	#puts(capture1.stats())
	#puts(capture2.stats())
end

