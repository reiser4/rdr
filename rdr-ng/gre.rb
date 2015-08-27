

class Gre < L2

  def initialize(cfg)
  	@pfx = "[GRE] "
    @printdebug = true
    cputs "#{@pfx}Configurazione per GRE: #{cfg}"
    @ipv4 = Array.new
    @ipv4.push(cfg['ipv4'])
  end

  def readPacket
    nil
  end

  def cputs(text)
    puts "#{text}" if @printdebug
  end

  def has_ip?(ip)
      @ipv4.each do |v4|
          addr = v4.split("/")[0]
          return true if addr == ip
      end
      return false
  end

end
