class LiveCollection < ActiveRecord::Base
  validates :shop_url, presence: true
  validates :shop_id, presence: true
  validates :collection_id, presence: true
  validates :title, presence: true
  validates :time_number, presence: true
  validates :time_type, presence: true

  def self.update
    lives = LiveCollection.all
    lives.each do |live|

      #calculate published_at_min for products
      num = live.time_number
      case live.time_type
        when "days"
          date = Time.now - num.days
        when "weeks"
          date = Time.now - num.weeks
        when "months"
          date = Time.now - num.months
        when "years"
          date = Time.now - num.years
      end

      #Get the shop from the saved data
      shop = Shop.find_by(:domain => live.shop_url)
      ShopifyAPI::Session.new(shop.domain, shop.token)
      ShopifyAPI::Base.site = shop.shopify_api_path
      #collection = ShopifyAPI::CustomCollection.where(:id => live.collection_id)
      collects = ShopifyAPI::Collect.where(:collection_id => live.collection_id)

      #clear out old products
      collects.each do |col|
        prod = ShopifyAPI::Product.find(col.product_id)
        if prod.published_at < date
          ShopifyAPI::Collect.delete(col.id)
        end
      end

      #Add the newest products
      products = ShopifyAPI::Product.where(:published_at_min => date)
      products.each do |prod|
        exist_test = ShopifyAPI::Collect.where(:collection_id => live.collection_id, :product_id => prod.id).count
        if exist_test == 0
          new_collect = ShopifyAPI::Collect.new(:collection_id => live.collection_id, :product_id => prod.id)
          new_collect.save!
        end
      end
    end
  end
end
