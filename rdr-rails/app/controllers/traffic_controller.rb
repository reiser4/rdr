class TrafficController < ApplicationController
  def index

  	lst = Dir.entries("rrd/")
  	lst.each do |file|
  		if file[-4,4] == ".rrd"
  			iface = file.chomp(".rrd")
  			@cmd = "cd rrd && rrdtool graph ../app/assets/images/rrd-"+iface+".png --start end-1h -t Traffico -v 'Bits/s' "+
  				"DEF:rx="+iface+".rrd:rx:AVERAGE DEF:tx="+iface+".rrd:tx:AVERAGE LINE1:tx#EE0000:Tx LINE1:rx#00EE00:Rx"
  			##@cmdoutput = system(@cmd)
  		end
  	end

  	@lst = Dir.entries("app/assets/images/")

  	# per ogni file eseguire comando



  	# mandare alla view la lista per visualizzare


  end
end
