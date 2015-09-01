

require 'ipaddr'


class Routingtable

	def initialize()
		@routes = Array.new
	end

	def nullNotMasked(ip)
		# prende in ingresso un ip in forma 192.168.1.254/24
		sip = ip.split("/")
		masked = IPAddr.new sip[0]
		unmasked = masked.mask(sip[1])
		return unmasked.to_s + "/" + sip[1]
	end

	def addRoute(dst, gw)
		# per ora supporta solo gw sotto forma di interfaccia (rotte connesse)

		dst = self.nullNotMasked(dst)

		@routes.push({"dst" => dst, "gw" => gw})

		cputs "Rotta aggiunta: #{dst} via #{gw}"
		cputs "Nuova rt: #{@routes}"

	end

	def cputs(text)
		puts "[ROUTE] #{text}"
	end

	def getRouteLen(route)
		#puts "Calcolo lunghezza #{route}"
		sroute = route.split("/")
		#puts "Trovata #{sroute[1]}"
		return sroute[1]
	end

	def routeMatch(route,dst)
		sroute = route.split("/")
		mroute = IPAddr.new sroute[0]
		mdst = IPAddr.new dst
		if mroute.mask(sroute[1]) == mdst.mask(sroute[1])
			return true
		else
			return false
		end
	end

	def getRouteFor(dst)
		puts "Inizio ricerca rotte verso #{dst}"
		#cerco la rotta piu` specifica per la destinazione
		len = 32
		while len >= 0 do
			
			#puts "Ne cerco una con lunghezza #{len}"
			@routes.each do |route|
				rlen = self.getRouteLen(route['dst'])
				if rlen.to_i == len.to_i
					if self.routeMatch(route['dst'],dst)	
						return route['gw']
					end

				end
			end
			len -= 1
			
		end
	end

end