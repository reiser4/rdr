class TrafficController < ApplicationController
  def index

  	# ricavare lista file 
  	lst = Dir.entries("rrd/")
  	lst.each do |file|
  		if file[-4,4] == ".rrd"
  			iface = file.chomp(".rrd")
  			@lst = iface
  			@cmd = "cd rrd && rrdtool graph ../app/assets/images/rrd-"+iface+".png --start end-1h "+
  				"DEF:rx="+iface+".rrd:rx:AVERAGE LINE2:rx#FF0000"
  			@cmd = system(@cmd)

  		end
  	end

  	@lst = Dir.entries("app/assets/images/")

  	# per ogni file eseguire comando



  	# mandare alla view la lista per visualizzare


  end
end
