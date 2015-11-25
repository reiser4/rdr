
require 'elasticsearch'


class Firewall


	def initialize()
		@pfx = "[FIREWALL] "
		#connessione al database
		@con = Mysql.new 'localhost', 'root', 'enrico', 'rdr'
		cputs "Mysql avviato: #{@con}"
		cputs "Avviato Firewall"
		@client = Elasticsearch::Client.new log: true


	end


	def ipMatch(range,dst)
		sroute = range.split("/")
		mroute = IPAddr.new sroute[0]
		mdst = IPAddr.new dst
		if mroute.mask(sroute[1]) == mdst.mask(sroute[1])
			return true
		else
			return false
		end
	end

	def cputs(msg)
		puts "#{@pfx}#{msg}"
	end

	def canAccept(packet, chain)
		src = packet.ip_saddr
		dst = packet.ip_daddr
		cputs "Verifico pacchetto: da #{src} a #{dst} su chain #{chain}"

	  	rs = @con.query("SELECT * FROM `firewallfilter` WHERE `chain` = '#{chain}' ORDER BY `id` ASC;")

		while row = rs.fetch_row do
			cputs "Regola incontrata: #{row}"
			if ipMatch(row[2], src)
				cputs "Sorgente corrisponde #{row[2]} #{src}"
				if ipMatch(row[3], dst)
					cputs "Destinazione corrisponde #{row[3]} #{dst}"
					action = row[4]
					if action == "drop"
						cputs "Droppo"
						return false
					end
					if action == "accept"
						cputs "Accetto"
						return true
					end
					if action == "elasticsearch"
						cputs "Loggo su elasticsearch"
						@client.index(
							index: 'rdr', 
							type: 'rdr-packet', 
							body: { 
								src: src, 
								dst: dst, 
								rule: row[0], 
								chain: chain,  }, 
							refresh: true)
					end
				end
			end
   		end
  		cputs "Nessuna regola trovata: accetto"
  		return true

	end

	def nat(packet, chain)
		src = packet.ip_saddr
		dst = packet.ip_daddr
		cputs "Natto pacchetto: da #{src} a #{dst} su chain #{chain}"

		rs = @con.query("SELECT * FROM `firewallnat` WHERE `chain` = '#{chain}' ORDER BY `id` ASC;")

		while row = rs.fetch_row do
			cputs "Regola incontrata: #{row}"
			if ipMatch(row[2], src)
				cputs "Sorgente corrisponde #{row[2]} #{src}"
				if ipMatch(row[3], dst)
					cputs "Destinazione corrisponde #{row[3]} #{dst}"
					if row[4] == "dst-nat"
						cputs "Riscrivo destinazione con dstnat #{dst} -> #{row[5]}"
						packet.ip_daddr = row[5]
						packet.ip_recalc
					end
				end
			end
   		end
  		cputs "Fine manipolazioni NAT"


		return packet

	end

end