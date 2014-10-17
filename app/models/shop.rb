class Shop < ActiveRecord::Base

  def self.store(session)
    shop = Shop.new(domain: session.url, token: session.token)
    shop.save!
    shop.id
  end

  def self.retrieve(id)
    return if id.blank?
    shop = Shop.find(id)
    ShopifyAPI::Session.new(shop.domain, shop.token)
  end
end
