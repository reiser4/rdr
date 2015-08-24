
require 'yaml'
require_relative 'gre'
require_relative 'eth'
require_relative 'switch'

puts "RDR NG v0.0.1"



class Layer3

  def initialize(config)
    puts "Inizializzo con configurazione: #{config}"

    @layers2 = Array.new

    cfg = config['config']['l2']
    cfg.keys.each do |type|
      puts "Avvio IF di tipo #{type}"

      mytype = type.slice(0,1).capitalize + type.slice(1..-1)

      clazz = Object.const_get(mytype)

      puts "Avvio #{clazz} con conf #{cfg[type]}"

      @layers2.push(clazz.new(cfg[type]))

    end
    


    puts "L2: #{@layers2}"

  end



  def start
    while 1==1 do
      @layers2.each do |l2|
        p = l2.readPacket
        if p
          self.processpacket(p)
        end
      end
    end
  end

  def processpacket(packet)
    puts "Elaboro pacchetto #{packet}"
  end

end



rdr = Layer3.new(YAML.load_file("config.yml"))

rdr.start()

puts rdr
