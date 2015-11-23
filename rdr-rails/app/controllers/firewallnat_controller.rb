class FirewallnatController < ApplicationController
  def index
  end

  def getdata
    @firewallnats = Firewallfilter.all
    render json: @firewallnats
  end
end
