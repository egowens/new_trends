class LiveCollection < ActiveRecord::Base
  validates :shop_url, presence: true
  validates :shop_id, presence: true
  validates :collection_id, presence: true
  validates :title, presence: true
  validates :time_number, presence: true
  validates :time_type, presence: true

#  def update
#   #calculate latest datetime
#   @checkdate = Time.no
#   @lives = LiveCollection.all

# #calculate published_at_min for products
#   num = @live_collection.time_number
#   case @live_collection.time_type
#     when "days"
#       date = Time.now - num.days
#     when "weeks"
#       date = Time.now - num.weeks
#     when "months"
#        date = Time.now - num.months
#      when "years"
#        date = Time.now - num.years
#    end
#
#    @lives.each do |live|
#      ShopifyAPI::Base.site = @lives.shop_url
#      @collection = CustomCollection.where(:id => live.collection_id)
#      @collect = Collect.where(:collection_id => live.collection_id)
#
#      #clear out old products
#      @collect.each do |col|
#        prod = Product.where(:id => col.product_id)
#        if
#      end
#
#    end
#  end
end
