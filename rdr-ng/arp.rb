

class Arp

	def initialize() #mymac
		@pfx = "[ARP] "
		#@mymac = mymac
		cputs "Avviato ARP"# con mac #{mymac}"
		@arptable = Array.new

	end

	def cputs(msg)
		puts "#{@pfx}#{msg}"
	end

	def parsepacket(packet,layers2)

		cputs "Elaboro pacchetto... " #" #{packet} "
		dst_ip = packet.arp_dst_ip_readable
		cputs "IP dst: #{dst_ip}"
		layers2.each do |l2|
			cputs "#{l2}"
			if l2.has_ip? dst_ip 
				if packet.arp_opcode == 1
					cputs "Ricevuto ARP REQUEST; ho io questo ip, devo rispondere"
					cputs "Mac: #{l2.mac} su #{l2}"
					src_mac = l2.mac
					dst_mac = packet.eth_saddr
					src_ip  = packet.arp_dst_ip
					dst_ip  = packet.arp_src_ip

					reply = self.arpreplypacket(src_mac, dst_mac, src_ip, dst_ip)
					l2.sendPacket(reply,layers2)
				else
					if packet.arp_opcode == 2
						cputs "Ricevuto ARP Reply!"

						@arptable.push({'ip' => packet.arp_src_ip_readable, 'mac' => packet.arp_src_mac_readable, 'interface' => l2})


					else
						cputs "Opcode: #{packet.arp_opcode}"
					end
				end
			end
		end
	end

	def arpreplypacket(srcmac, dstmac, srcip, dstip)

		cputs "Genero pacchetto arpreply con parametri: #{srcmac} #{dstmac} #{srcip} #{dstip}"
		arpreply = PacketFu::ARPPacket.new()

		arpreply.eth_saddr = srcmac
		arpreply.eth_daddr = dstmac
		
		arpreply.arp_opcode = 2
		arpreply.arp_dst_ip = dstip
		arpreply.arp_daddr_mac = dstmac
		arpreply.arp_saddr_mac = srcmac
		arpreply.arp_src_ip = srcip
		File.write('/var/www/html/pkt6', arpreply)
		return arpreply
	end

	def askmac(ip,l2)
		#l2 passato in formato oggetto

		arprequest = PacketFu::ARPPacket.new()

		puts "Creo richiesta con mac l2 #{l2.mac()}"

		arprequest.eth_saddr = l2.mac()
		arprequest.eth_daddr = "ff:ff:ff:ff:ff:ff" #verso broadcast...

		dst_ip = IPAddr.new ip
		src_ip = IPAddr.new l2.ipv4

		arprequest.arp_opcode = 1
		arprequest.arp_dst_ip = dst_ip.hton()
		arprequest.arp_src_ip = src_ip.hton()
		arprequest.arp_daddr_mac = "ff:ff:ff:ff:ff:ff"
		arprequest.arp_saddr_mac = l2.mac()

		l2.sendPacket(arprequest,l2)
		puts "Richiesta inviata..."

	end

	def getMac(ip,l2)

		@arptable.each do |arpentry|
			if arpentry['ip'] == ip
				return arpentry['mac']
			end
		end

		#non ho trovato nulla...

		self.askmac(ip,l2)

	end

end