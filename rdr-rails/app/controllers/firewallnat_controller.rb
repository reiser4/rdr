class FirewallnatController < ApplicationController
  def index
  	@firewallnat = Firewallnat.all
  end

  def getdata
    @firewallnats = Firewallfilter.all
    render json: @firewallnats
  end
end
