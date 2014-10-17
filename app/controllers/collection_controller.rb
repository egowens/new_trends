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
    if @shop_collection.save
      flash[:success] = "New Collection Added!"
      @included_products = ShopifyAPI::Product.where(:published_at_min => @collection.published_at_min)

      @included_products.each do |prod|
        collect = ShopifyAPI::Collect.new("collection_id" => @shop_collection.id, "product_id" => prod.id)
        collect.save!
      end

      redirect_to '/' #redirect to /collect to add all the products since the date
    else
      redirect_to '/collection/new'
    end
  end

  private

  def collection_params
    params.require(:collection).permit(:title, :published_at_min)
  end

  def mod_params
    mod = collection_params
    mod[:published_at_min] = Time.strptime(mod[:published_at_min], "%m/%d/%Y %H:%M %p")
    mod
  end
end
