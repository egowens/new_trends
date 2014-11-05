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
    @shop_collection = ShopifyAPI::CustomCollection.new(:title => @collection.title)


    #Get applicable products for collection
    @included_products = ShopifyAPI::Product.where(:published_at_min => @collection.published_at_min)

    if @included_products != nil
      #save the collection to shopify
      @shop_collection.save
      @collection.collection_id = @shop_collection.id

      #Save new collection to database for validation
      if @collection.save
        flash[:success] = "New Collection Created!"

        #Add applicable products to the new collection
        @included_products.each do |prod|
          collect = ShopifyAPI::Collect.new("collection_id" => @shop_collection.id, "product_id" => prod.id)
          collect.save!
        end
      else
        render 'new'
      end
    else
      flash[:alert] = "No Products found"
    end
      redirect_to '/'
  end

  def destroy
    @collection = Collection.find_by(id: params[:id])
    begin
      @shop_col = ShopifyAPI::CustomCollection.find(@collection.collection_id)
      @shop_col.destroy
      @collection.destroy
    rescue ActiveResource::ResourceNotFound
      @collection.destory
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
