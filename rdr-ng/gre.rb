
class Gre < L2

  def initialize(cfg)
    super(cfg)
    @printdebug = true
    cputs "#{@pfx}Configurazione per GRE: #{cfg}"
    @ipv4 = Array.new
    @ipv4.push(cfg['ipv4'])
    @packetqueue = Array.new
  end

  def readPacket
    nil
  end


  def has_ip?(ip)
      @ipv4.each do |v4|
          addr = v4.split("/")[0]
          return true if addr == ip
      end
      return false
  end

  def parsepacket(packet,layers2)
    cputs "Processo pacchetto gre" #: #{packet}"

    dst_ip = packet.ip_daddr
    cputs "Pacchetto per #{dst_ip}"
    layers2.each do |l2|
      cputs "#{l2}"
      if l2.has_ip? dst_ip
        cputs "Ho io questo ip, lo passo al layer 3"
        packet.payload.to_s.split("").each do |pbyte|
          print "#{pbyte.ord.to_s(16)} " #.rjust(8, "0")} "
        end
        puts "."

        emac = "\x00\x00\x00\x00\x00\x00"

        pkg = emac + emac + "\x08" + packet.payload.to_s[3..-1]

        eth_pkg = PacketFu::Packet.parse pkg

        eth_pkg.to_s.split("").each do |pbyte|
          print "#{pbyte.ord.to_s(16).rjust(2, "0")} " #.rjust(8, "0")} "
        end
        puts "fine pacchetto creato"


        packet.to_s.split("").each do |pbyte|
          print "#{pbyte.ord.to_s(16).rjust(2, "0")} " #.rjust(8, "0")} "
        end
        puts "fine pacchetto originale"

        puts "#{eth_pkg.class}"
        puts " #{eth_pkg.ip_saddr} #{eth_pkg.ip_daddr}"

        if eth_pkg.ip_saddr == dst_ip
          puts "Pacchetto KEEPALIVE GRE"

          #devo forgiare una risposta

          hisip = eth_pkg.ip_dst
          myip = eth_pkg.ip_src

          ####puts "#{hisip} #{hisip.class} #{hisip.chr}"

          bhisip = [24, 16, 8, 0].collect {|b| ((hisip >> b) & 255 ).chr}.join("")
          bmyip = [24, 16, 8, 0].collect {|b| ((myip >> b) & 255 ).chr}.join("")


          response = PacketFu::IPPacket.new
          response.eth_daddr = packet.eth_saddr
          response.eth_saddr = packet.eth_daddr
          response.ip_saddr = dst_ip
          response.ip_daddr = packet.ip_saddr
          response.ip_proto = packet.ip_proto
          response.ip_ttl = packet.ip_ttl
          #cputs "#{response} #{response.payload}"
          response.payload = 
          ("\x00\x00\x08\x00".force_encoding('ASCII-8BIT') + 
            "\x45\x00\x00\x18\x00\x00\x00\x00\xff\x2f\x00\x00".force_encoding('ASCII-8BIT') + 
           bhisip + bmyip + "\x00\x00\x00\x00")
          response.recalc
          #cputs "#{response} #{response.payload}"
          
          ###cputs "Risposta: #{response}"
          cputs "Invio su #{l2.name()}"
          l2.sendPacket(response)
          ###response.to_w(l2.name())

          response.to_s.split("").each do |pbyte|
            print "#{pbyte.ord.to_s(16).rjust(2, "0")} " #.rjust(8, "0")} "
          end
          puts "fine pacchetto risposta"

        else
          puts "Pacchetto GRE normale"
        end



      end
    end

  end

end
