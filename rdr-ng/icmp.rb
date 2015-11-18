

class Icmp


	def initialize() #mymac
		@pfx = "[ICMP] "
		#@mymac = mymac
		cputs "Avviato ICMP"# con mac #{mymac}"

	end

	def cputs(msg)
		puts "#{@pfx}#{msg}"
	end

	def parsepacket(packet,layers2)
		#cputs "Elaboro pacchetto #{packet} "
		dst_ip = packet.ip_daddr
		cputs "IP dst: #{dst_ip}"
		layers2.each do |l2|
			cputs "#{l2}"
			if l2.has_ip? dst_ip
				cputs "Ho io questo ip, devo rispondere"

				src_mac = l2.mac
				dst_mac = packet.eth_saddr
				src_ip  = packet.ip_daddr
				dst_ip  = packet.ip_saddr

				reply = self.icmpreplypacket(packet, src_mac, dst_mac, src_ip, dst_ip)
				l2.sendPacket(reply,layers2)
			end
		end
	end

	def icmpreplypacket(eth_pkg,src_mac,dst_mac, src_ip, dst_ip)

		puts "Tipo: #{eth_pkg.icmp_type}"
		if eth_pkg.icmp_type == 8
			puts "Ping?"

			eth_pkg.eth_daddr = dst_mac
			eth_pkg.eth_saddr = src_mac
			eth_pkg.ip_daddr = dst_ip
			eth_pkg.ip_saddr = src_ip
			eth_pkg.icmp_type = 0
			eth_pkg.icmp_calc_sum
			return eth_pkg
		end
	end

end