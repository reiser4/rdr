

class Arp

	def initialize() #mymac
		@pfx = "[ARP] "
		#@mymac = mymac
		cputs "Avviato ARP"# con mac #{mymac}"

	end

	def cputs(msg)
		puts "#{@pfx}#{msg}"
	end

	def parsepacket(packet,layers2)

		cputs "Elaboro pacchetto #{packet} "
		dst_ip = packet.arp_dst_ip_readable
		cputs "IP dst: #{dst_ip}"
		layers2.each do |l2|
			cputs "#{l2}"
			if l2.has_ip? dst_ip
				cputs "Ho io questo ip, devo rispondere"

				src_mac = l2.mac
				dst_mac = packet.eth_saddr
				src_ip  = packet.arp_dst_ip
				dst_ip  = packet.arp_src_ip

				reply = self.arpreplypacket(src_mac, dst_mac, src_ip, dst_ip)
				l2.sendPacket(reply)
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

end