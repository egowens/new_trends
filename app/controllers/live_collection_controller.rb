class LiveCollectionController < ApplicationController

  around_filter :shopify_session

  def new
    @live = LiveCollection.new
  end

  def create
    @live = LiveCollection.new(live_params)
    if @live.save
      flash[:success] = "New live collection created!"
      #add logic for live collections
    end
  end

  private

  def live_params
    params.require(:live).permit(:shop_url, :title, :time_num, :time_type)
  end
end
