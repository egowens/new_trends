class LiveCollection < ActiveRecord::Base
  validates :shop_url, presence: true
  validates :shop_id, presence: true
  validates :collection_id, presence: true
  validates :title, presence: true
  validates :time_number, presence: true
  validates :time_type, presence: true

  def update
    @lives = LiveCollection.all
    @lives.each do |live|

      #calculate published_at_min for products
      num = @live.time_number
      case @live.time_type
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
      ShopifyAPI::Base.site = @lives.shop_url
      @collection = ShopifyAPI::CustomCollection.where(:id => live.collection_id)
      @collect = ShopifyAPI::Collect.where(:collection_id => live.collection_id)

      #clear out old products
      @collect.each do |col|
        prod = ShopifyAPI::Product.where(:id => col.product_id)
        if prod.published_at < date
          col.delete
        end
      end

      #Add the newest products
      @products = ShopifyAPI::Products.where(:published_at_min => date)
      @products.each do |allprod|
        new_collect = ShopifyAPI::Collect.where(:collection_id => live.collection_id, :product_id => allprod.id)
        new_collect ||= ShopifyAPI::Collect.new(:collection_id => live.collection_id, :product_id => allprod.id)
        new_collect.save
      end
    end
  end

end
