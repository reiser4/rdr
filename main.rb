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

