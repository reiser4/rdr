class FirewallfilterController < ApplicationController
  def index
  	@firewallfilters = Firewallfilter.all
  end

end
