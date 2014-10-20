class LiveCollectionController < ApplicationController

  around_filter :shopify_session

  def new
    @live_collection = LiveCollection.new
  end

  def create
    @live_collection = LiveCollection.new(live_params)
    @shop_live_collection = ShopifyAPI::CustomCollection.new("title" => @live_collection.title)

    #calculate published_at_min for products
    num = @live_collection.time_number
    case @live_collection.time_type
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

    if @included_products != nil
      #save the collection to shopify
      @shop_live_collection.save
      @live_collection.shop_id = shop_session.id
      @live_collection.collection_id = @shop_live_collection.id
      if @live_collection.save
        flash[:success] = "New Live Collection Created!"

        #Add applicable products to the new collection
        @included_products.each do |prod|
          collect = ShopifyAPI::Collect.new("collection_id" => @shop_live_collection.id, "product_id" => prod.id)
          collect.save!
        end
      else
        render 'new'
      end
    else
      flash[:alert] = "No products found"
    end
      redirect_to '/'
  end

  private

  def live_params
    params.require(:live_collection).permit(:shop_url, :title, :time_number, :time_type)
  end
end
