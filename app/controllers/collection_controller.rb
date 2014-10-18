class CollectionController < ApplicationController

  around_filter :shopify_session


  def index
    @collections = ShopifyAPI::CustomCollections.all
  end

  def show
    @newest = ShopifyAPI::CustomCollection.find(:all, :params => {:limit => 5, :order => "created_at DESC"})
  end

  def new
    @collection = Collection.new
  end

  def create
    @collection = Collection.new(mod_params)
    @shop_collection = ShopifyAPI::CustomCollection.new("title" => @collection.title)

    #Save new collection to database for validation
    if @collection.save

      #Save collection to Shopify store
      @shop_collection.save
      flash[:success] = "New Collection Added!"

      #Get applicable products for collection
      @included_products = ShopifyAPI::Product.where(:published_at_min => @collection.published_at_min)

      #Add applicable products to the new collection
      @included_products.each do |prod|
        collect = ShopifyAPI::Collect.new("collection_id" => @shop_collection.id, "product_id" => prod.id)
        collect.save!
      end

      #Remove the database entry since its just for errors
      @collection.delete

      #Redirect to root
      redirect_to '/'

    #if database save doesn't work, render new and show errors
    else
      render 'new'
    end
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
