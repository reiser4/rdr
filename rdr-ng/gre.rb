

class Gre

  def initialize(cfg)
  	@pfx = "[GRE] "
    cputs "#{@pfx}Configurazione per GRE: #{cfg}"
  end

  def readPacket
    nil
  end

  def cputs(text)
    puts "#{text}" if @printdebug
  end

end
