class PagesController < ApplicationController
  layout 'no_container', only: :home

  def current_status
    @current_status = StatusPage.new.current_status

    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def home; end

  def mentions; end

  def cgu; end

  def redoc; end
end
