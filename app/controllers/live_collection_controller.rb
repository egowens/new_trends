class LiveCollectionController < ApplicationController

  around_filter :shopify_session

  def new
    @live = LiveCollection.new
  end

  def create
    @live = LiveCollection.new(live_params)
    @shop_live_collection = ShopifyAPI::CustomCollection.new("title" => @live.title)

    if @live.save

      #save collection to shopify store
      @shop_collection.save
      flash[:success] = "New Live Collection Created!"

      #calculate afterdate
      num = @live.time_num
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

      #get applicable products for collection
      @included_products = ShopifyAPI::Product.where(:published_at_min => date)

      #Add applicable products to the new collection
      @included_products.each do |prod|
        collect = ShopifyAPI::Collect.new("collection_id" => @shop_collection.id, "product_id" => prod.id)
        collect.save!
      end
    end
  end

  private

  def live_params
    params.require(:live).permit(:shop_url, :title, :time_num, :time_type)
  end
end
