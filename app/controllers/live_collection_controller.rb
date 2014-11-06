class LiveCollectionController < ApplicationController

  around_filter :shopify_session

  def new
    @live_collection = LiveCollection.new
  end

  def create
    @live_collection = LiveCollection.new(live_params)
    @shop_live_collection = ShopifyAPI::CustomCollection.new(:title => @live_collection.title)
    @shop = ShopifyAPI::Shop.current

    if @live_collection.save

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

      #try saving the collection to Shopify, if it doesn't work, rescue and do validations on local data
      begin
        @shop_live_collection.save

      rescue
        flash[:warning] = "Could not save new collection to Shopify"
        @live_collection.destroy
        render 'new'
        return
      end

      #Add shopify values and save local data
      @live_collection.shop_id = @shop.id
      @live_collection.shop_url = @shop.domain
      @live_collection.collection_id = @shop_live_collection.id

      @live_collection.save
      flash[:success] = "Live Collection '#{@collection.title}' Created!"

      #get applicable products for collection
      @included_products = ShopifyAPI::Product.where(:published_at_min => date)

      #Add applicable products to the new collection
      @included_products.each do |prod|
        collect = ShopifyAPI::Collect.new(:collection_id => @shop_live_collection.id, :product_id => prod.id)
        collect.save!
      end

      redirect_to '/'
    else
      render 'new'
    end
  end

  def destroy
    @live = LiveCollection.find_by(id: params[:id])
    begin
      @shop_col = ShopifyAPI::CustomCollection.find(@live.collection_id)
      @shop_col.destroy
      @live.destroy
    rescue ActiveResource::ResourceNotFound
      @live.destroy
    end

    flash[:warning] = "The live collection '#{@live.title}' has been deleted."
    redirect_to root_url

  end

  private

  def live_params
    params.require(:live_collection).permit(:title, :time_number, :time_type)
  end
end
