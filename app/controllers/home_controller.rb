class HomeController < ApplicationController

  before_filter :allow_iframes
  around_filter :shopify_session, :except => 'welcome'

  def welcome
    current_host = "#{request.host}#{':' + request.port.to_s if request.port != 80}"
    @callback_url = "http://#{current_host}/login"
  end

  def index
    @shop = ShopifyAPI::Shop.current
    @collections = Collection.where(:shop_id => @shop.id)
    @live_collections = LiveCollection.where(:shop_id => @shop.id)
  end

  def support
  end

  private

  def allow_iframes
    response.headers.delete('X-Frame-Options')
  end
end
