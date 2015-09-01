
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

puts "RDR NG v0.0.1"



class Layer3

  def initialize(config)
    @pfx = "[MAIN] "
    @printdebug = true
    cputs "#{@pfx}Inizializzo con configurazione: #{config}"
    @arp = Arp.new
    @icmp = Icmp.new
    @layers2 = Array.new
    cfg = config['config']['l2']
    cfg.keys.each do |type|
      cputs "#{@pfx}Avvio IF di tipo #{type}"
      mytype = type.slice(0,1).capitalize + type.slice(1..-1)
      clazz = Object.const_get(mytype)
      cputs "#{@pfx}Avvio #{clazz} con conf #{cfg[type]}"
      @layers2.push(clazz.new(cfg[type]))
    end
    cputs "#{@pfx}L2: #{@layers2}"
  end

  def start
    while 1==1 do
      @layers2.each do |l2|
        p = l2.readPacket
        if p
          self.processpacket(p,l2)
        end
      end
    end
  end

  def processpacket(packet,from)
    cputs "#{@pfx}Elaboro pacchetto ricevuto da #{from}..."
    cputs "#{@pfx}#{packet.class}"

    if packet.class == PacketFu::ARPPacket
      #pacchetto di tipo ARP per me?
      @arp.parsepacket(packet,@layers2)      
    end
    if packet.class == PacketFu::ICMPPacket
      #icmp per me?
      @icmp.parsepacket(packet,@layers2)
    end
  end
  def cputs(text)
    puts "#{text}" if @printdebug
  end
end



rdr = Layer3.new(YAML.load_file("config.yml"))
rdr.start()
puts rdr
