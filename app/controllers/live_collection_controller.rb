class LiveCollectionController < ApplicationController

  around_filter :shopify_session

  def new
    @live_collection = LiveCollection.new
  end

  def create
    @live_collection = LiveCollection.new(live_params)
    @shop_live_collection = ShopifyAPI::CustomCollection.new("title" => @live_collection.title)

    if @live_collection.save

      #save collection to shopify store
      #REARRANGE SO THAT COLLECTION IS NOT SAVED IN SHOPIFY IF NO PRODUCTS ARE FOUND ***************************
      @shop_live_collection.save
      flash[:success] = "New Live Collection Created!"

      #calculate afterdate
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
        #Add applicable products to the new collection
        @included_products.each do |prod|
          collect = ShopifyAPI::Collect.new("collection_id" => @shop_live_collection.id, "product_id" => prod.id)
          collect.save!
        end
      else
        flash[:alert] = "No products found"
        @live_collection.delete
      end

      redirect_to '/'
    else
      render 'live_collection/new'
    end
  end

  private

  def live_params
    params.require(:live_collection).permit(:shop_url, :title, :time_number, :time_type)
  end
end
