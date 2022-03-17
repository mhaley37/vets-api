class SrestatusController < ApplicationController
skip_before_action :authenticate, only: :index
  def index
    #render html: "<h1>works</h1>".html_safe
    redirect_to("http://google.com")
  end
end
