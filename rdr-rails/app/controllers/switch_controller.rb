class SwitchController < ApplicationController
  def index
  end

  def getdata
    @hosts = Switchost.all
    render json: @hosts
  end
end
