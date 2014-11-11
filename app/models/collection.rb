class Collection < ActiveRecord::Base
  validates :title, presence: true, uniqueness: true
  validates :published_at_min, presence: true

  def self.update
    collections = Collection.all
    collections.each do |coll|

      #get the shop from the saved data and start a new session
      shop = Shop.find_by(:domain => coll.shop_url)
      ShopifyAPI::Session.new(shop.domain, shop.token)
      ShopifyAPI::Base.site = shop.shopify_api_path

      #check if the collection has been deleted by the shopify side
      begin
        ShopifyAPI::CustomCollection.find(coll.collection_id)
      rescue ActiveResource::ResourceNotFound
        coll.delete
        next
      end

      #Add the newest products
      products = ShopifyAPI::Product.where(:published_at_min => coll.published_at_min)
      products.each do |prod|
        exist_test = ShopifyAPI::Collect.where(:collection_id => coll.collection_id, :product_id => prod.id).count
        if exist_test == 0
          new_collect = ShopifyAPI::Collect.new(:collection_id => coll.collection_id, :product_id => prod.id)
          new_collect.save!
        end
      end

      #reset the base site
      ShopifyAPI::Base.site = nil

    end
  end
end
