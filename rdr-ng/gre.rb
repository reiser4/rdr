

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
    cputs "Processo pacchetto gre: #{packet}"

    dst_ip = packet.ip_daddr
    cputs "Pacchetto per #{dst_ip}"
    layers2.each do |l2|
      cputs "#{l2}"
      if l2.has_ip? dst_ip
        cputs "Ho io questo ip, lo passo al layer 3"
        #todo: da completare...
      end
    end

  end

end
