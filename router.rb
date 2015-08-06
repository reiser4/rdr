
puts "Avvio router ipv4"

require 'ipaddr'
require_relative 'arp'

$routes = Array.new

class Route
	def initialize(dst, gw)
		puts "Creo rotta verso #{dst} tramite #{gw}"
		@dst = dst
		@gw = gw
	end

	def gw
		return @gw
	end

	def len
		sdst = @dst.split("/")
		return sdst[1].to_i
	end

	def len?(length)
		return self.len == length
	end

	def match?(dest)
		myip = IPAddr.new(dest)
		myip = myip.mask(self.len)
		#puts "IP: #{myip}"
		myroute = IPAddr.new(@dst)
		myroute = myroute.mask(self.len)
		#puts "Rotta: #{myroute}"
		if myip == myroute
			return true
		else
			return false
		end
	end

	
	def self.getRouteFor(dst,routes)
		puts "Inizio ricerca rotte verso #{dst}"
		#cerco la rotta piu` specifica per la destinazione
		len = 32
		while len >= 0 do
			
			#puts "Ne cerco una con lunghezza #{len}"
			routes.each do |route|
				rlen = route.len
				#puts "#{rlen}"
				if route.len? len
					puts "Trovata len #{len}"
					if route.match? dst
						return route
					end
				end
			end
			len -= 1
			
		end
	end
	
end

def getInterfaceForIp(dst_ip)
	#todo: supporta solo rotte connesse (gateway = interfaccia)
	puts "Devo inviare un pacchetto per l'ip #{dst_ip}"
	route = Route.getRouteFor(dst_ip,$routes)
	puts "Rotta migliore: #{route}"
	puts "Gateway: #{route.gw}"
	gateway = route.gw
	return gateway
end

def getMyIpOnInterface(interface,config)
	puts "Cerco mio ip sull'interfaccia #{interface}"
	#todo: pericoloso cercare la chiave direttamente..
	fullip = config['interfaces'][interface]['ipv4']
	sfullip = fullip.split("/")
	puts "Trovato: #{sfullip[0]}"
	return sfullip[0]
end


def start_router(config)
	puts "Configurazione router: #{config}"

	
	config['interfaces'].keys.each do |iface|
		puts "Configuro per l'interfaccia #{iface}"
		myconf = config['interfaces'][iface]
		puts "Settaggio: #{myconf}"

		$routes.push(Route.new(myconf['ipv4'],iface))

	end

	puts "Ascolto per pacchetti"


	captures = Hash.new	

	puts "Avvio catture"
	config['interfaces'].keys.each do |iface|
		puts iface
		captures[iface] = PCAPRUB::Pcap.open_live(iface, 65535, true, 0)
	end
	puts "Catture pronte: #{captures}"

	while 1==1
		captures.keys.each do |cap|
			pkg = captures[cap].next()
			if pkg
				eth_pkg = PacketFu::Packet.parse pkg
				puts "Pacchetto di classe #{eth_pkg.class}"
				pclass = eth_pkg.class
				if pclass == PacketFu::InvalidPacket
					puts "Pacchetto non valido!?"
				else
					if pclass == PacketFu::ARPPacket
						puts "Ricevuto pacchetto ARP"
						arpdst = eth_pkg.arp_dst_ip_readable
						puts "Destinatario: #{arpdst}"

						config['interfaces'].keys.each do |iface|
							myconf = config['interfaces'][iface]
							if arpdst == myconf['ipv4'].split("/")[0]
								puts "Pacchetto per me!"

								#mi hanno fatto una richiesta o dato una risposta?
								op = eth_pkg.arp_opcode
								puts "Optype: #{op}"

								if op == 1
									puts "Ricevuto arp request: rispondo con arp reply"
									#todo: verifica se l'interfaccia corrisponde
									arpreply = PacketFu::ARPPacket.new()

									puts "Rispondo su #{cap}"
									puts "#{arpreply}"
									mymac = "00:01:02:03:04:05"
									mymachex = "\x00\x01\x02\x03\x04\x05"
									#compilo campi layer 2
									arpreply.eth_saddr = mymac
									arpreply.eth_daddr = eth_pkg.eth_saddr
									
							
									#campi layer 3
									arpreply.arp_opcode = 2
									arpreply.arp_dst_ip = eth_pkg.arp_src_ip
									arpreply.arp_dst_mac = eth_pkg.arp_src_mac
									arpreply.arp_src_mac = mymachex
									arpreply.arp_src_ip = eth_pkg.arp_dst_ip
									puts "Invio..."
									arpreply.to_w(cap)
									File.write('/var/www/html/pkt', arpreply)

								else

									puts "Ricevuto arp reply: popolo tabella arp"
									
									$arptable.push('ip' => eth_pkg.arp_src_ip_readable, 'mac' => eth_pkg.arp_src_mac_readable, 'interface' => cap)

									puts "Nuova arptable: #{$arptable}"

								end

							end
						end
					else #pacchetto non arp
						src = eth_pkg.eth_saddr
						dst = eth_pkg.eth_daddr 
						puts "Pacchetto per #{dst}"
						if dst == "00:01:02:03:04:05"
							puts "Pacchetto per me da inoltrare!"
							dst_ip = eth_pkg.ip_daddr
							puts "Pacchetto per #{dst_ip}"
							route = Route.getRouteFor(dst_ip,$routes)
							print "Rotta aggiudicata: #{route} #{route.gw}"

							### devo modificare il pacchetto: cambiare mac sorgente, mac destinazione, togliere 1 al ttl

							dst_macaddr = getMacForIp(dst_ip,config)
							print "Mac destinazione: #{dst_macaddr}"

							if dst_macaddr != ""
								puts "Invio! da mio mac verso #{dst_macaddr}"
								eth_pkg.eth_daddr = dst_macaddr
								eth_pkg.eth_saddr = "00:01:02:03:04:05"
								eth_pkg.to_w(route.gw)
							else
								puts "non invio: non ho mac destinazione..."
							end

						end
					end
				end
			end
		end
	end
end



