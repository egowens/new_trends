class CollectionController < ApplicationController

  around_filter :shopify_session

  def new
    @collection = Collection.new
  end

  def create
    @collection = Collection.new(mod_params)
    @shop_collection = ShopifyAPI::CustomCollection.new(:title => @collection.title)
    @shop = ShopifyAPI::Shop.current

    if @collection.save

      #try saving the collection to Shopify, if it doesn't work, rescue and do validations on local data
      begin
        @shop_collection.save

      rescue #stop if there is a problem with saving to the shop
        flash[:warning] = "Could not save new collection to Shopify"
        @collection.destroy
        render 'new'
        return
      end


      #Add shopify values and save local data
      @collection.shop_id = @shop.id
      @collection.shop_url = @shop.domain
      @collection.collection_id = @shop_collection.id

      @collection.save
      flash[:success] = "Collection '#{@collection.title}' Created!"

      #Get applicable products for collection
      @included_products = ShopifyAPI::Product.where(:published_at_min => @collection.published_at_min)

      #Add applicable products to the new collection
      @included_products.each do |prod|
        collect = ShopifyAPI::Collect.new(:collection_id => @shop_collection.id, :product_id => prod.id)
        collect.save!
      end

      redirect_to '/'
    else
      render 'new'
    end
  end

  def destroy
    @collection = Collection.find_by(id: params[:id])
    begin
      @shop_col = ShopifyAPI::CustomCollection.find(@collection.collection_id)
      @shop_col.destroy
      @collection.destroy
    rescue ActiveResource::ResourceNotFound
      @collection.destroy
    end

    flash[:warning] = "'#{@collection.title}' deleted"
    redirect_to root_url

  end

  private

  def collection_params
    params.require(:collection).permit(:title, :published_at_min)
  end

  #chage datetime collected from view to a proper datetime
  def mod_params
    mod = collection_params
    if mod[:published_at_min] != ''
      mod[:published_at_min] = Time.strptime(mod[:published_at_min], "%m/%d/%Y %H:%M %p")
    end
    mod
  end
end
