
puts "Carico supporto ad ARP"


$arptable = Array.new
#todo: rifare come array di oggetti

def getMacForIp(ip,config)

	puts "Cerco il MAC dell'ip #{ip}"
	# procedura che cerca se ho gia` il mac di un certo ip
	# oppure fa la richiesta arp e aspetta la risposta
	$arptable.each do |arpentry|

		if arpentry['ip'] == ip
			mac = arpentry['mac']
			interface = arpentry['interface']
			puts "Trovato! #{interface} #{mac}"
			return mac
		end

	end

	puts "Non trovato nella tabella arp..."

	arprequest = PacketFu::ARPPacket.new()
	puts "#{arprequest}"
	mymac = "00:01:02:03:04:05"
	mymachex = "\x00\x01\x02\x03\x04\x05"
	#compilo campi layer 2
	arprequest.eth_saddr = mymac
	arprequest.eth_daddr = "ff:ff:ff:ff:ff:ff" #la request e` verso broadcast
	
	#campi layer 3
	arprequest.arp_opcode = 1 #request

	outinterface = getInterfaceForIp(ip)
	srcip = getMyIpOnInterface(outinterface,config)

	dst_ip = IPAddr.new ip
	src_ip = IPAddr.new srcip

	arprequest.arp_dst_ip = dst_ip.hton()
	arprequest.arp_dst_mac = "\x00\x00\x00\x00\x00\x00"
	arprequest.arp_src_mac = mymachex
	arprequest.arp_src_ip = src_ip.hton()
	
	puts "Invio..."
	arprequest.to_w(outinterface)

	File.write('/var/www/html/pkt_ar', arprequest)

	puts "Attendo risposta per tre secondi"

	return ""

end