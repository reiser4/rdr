
require 'yaml'
require 'pcaprub'
require 'packetfu'

require_relative 'l2'
require_relative 'gre'
require_relative 'eth'
require_relative 'switch'
require_relative 'hub'
require_relative 'arp'
require_relative 'icmp'
require_relative 'routingtable'
require_relative 'firewall'

puts "RDR NG v0.0.1"



class Layer3

  def initialize(config)
    @pfx = "[MAIN] "
    @printdebug = true
    cputs "#{@pfx}Inizializzo con configurazione: #{config}"
    @firewall = Firewall.new
    @arp = Arp.new
    @icmp = Icmp.new
    @layers2 = Array.new
    @routingtable = Routingtable.new
    cfg = config['config']['l2']
    cfg.keys.each do |type|
      cputs "#{@pfx}Avvio IF di tipo #{type}"
      mytype = type.slice(0,1).capitalize + type.slice(1..-1)
      clazz = Object.const_get(mytype)
      cputs "#{@pfx}Avvio #{clazz} con conf #{cfg[type]}"
      @layers2.push(clazz.new(cfg[type]))

      @routingtable.addRoute(cfg[type]['ipv4'], cfg[type]['name'])

    end
    cputs "#{@pfx}L2: #{@layers2}"
  end

  def start
    while 1==1 do
      @layers2.each do |l2|
        p = l2.readPacket(@layers2)
        if p
          self.processpacket(p,l2)
        end
      end
    end
  end

  def processpacket(packet,from)
    cputs "#{@pfx}Elaboro pacchetto ricevuto da #{from}..."
    cputs "#{@pfx}#{packet.class}"

    if packet.class == PacketFu::InvalidPacket
      return
    end

    if packet.class == PacketFu::ARPPacket
      #pacchetto di tipo ARP per me?
      @arp.parsepacket(packet,@layers2)      
    else

      forme = false
      dst_ip = packet.ip_daddr
      cputs "IP dst: #{dst_ip}"

      if dst_ip == "255.255.255.255"
        forme = true
      else
        @layers2.each do |l2|
          cputs "#{l2}"
          if l2.has_ip? dst_ip
            cputs "Ho io questo ip, devo rispondere"
            forme = true
          end
        end
      end

      if forme
        if packet.class == PacketFu::ICMPPacket
          #icmp per me?
          #todo: togliere controllo. il pacchetto e` per me!
          @icmp.parsepacket(packet,@layers2)
        end

        if packet.class == PacketFu::IPPacket
          #pacchetto gre?
          proto = packet.ip_proto
          cputs "Pacchetto IP di tipo #{proto}"
          if proto == 47
            cputs "Passo al l2 GRE, se esiste..."
            @layers2.each do |l2|
              if l2.class == Gre
                cputs "Mando a #{l2}"
                l2.parsepacket(packet,@layers2)
              end
            end
          end
        end
      else
        cputs "Pacchetto non per me, devo forwardare!!!"

        if @firewall.canAccept(packet, "forward")

          packet = @firewall.nat(packet, "dstnat")
          dst_ip = packet.ip_daddr
          router = @routingtable.getRouteFor(dst_ip)

          if !router
            puts "Non ho trovato rotta verso #{dst_ip}"
          else

            #todo: funziona solo con rotte connesse...
            cputs "Interfaccia dst: #{router}"

            cputs "Cerco mac DST"

            macdst = false
            gotif = false
            srcmac = false
            iface = false
            @layers2.each do |l2|
              if l2.name() == router
                puts "Assegno srcmac"
                srcmac = l2.mac()
                puts "Srcmac: #{srcmac}"
                macdst = @arp.getMac(dst_ip,l2)
                gotif = true
                iface = l2
                puts "Nome matchato #{l2}"
              else 
                puts "Nome non matchato: #{l2} #{l2.name()}"
              end
            end

            if !gotif
              puts "Nessun layer2 chiamato #{router} ?!?!?"
            end
            if !macdst
              puts "Non ho trovato il mac a cui inoltrare la richiesta..."
            else
              if gotif
                puts "Srcmac: #{srcmac}"
                packet.eth_saddr = srcmac
                packet.eth_daddr = macdst
                puts "Invio a #{router}"
                iface.sendPacket(packet,@layers2)
              else
                puts "Ho mac ma non ho interfaccia..."
              end
            end


          # riscrivo mac

          # tolgo TTL

          end
        else
          puts "Pacchetto droppato da regola del firewall"
        end


      end
    end


  end
  def cputs(text)
    puts "#{text}" if @printdebug
  end
end



rdr = Layer3.new(YAML.load_file("config.yml"))
rdr.start()
puts rdr
