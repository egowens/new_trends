class AddLastRunToLiveCollection < ActiveRecord::Migration
  def change
    add_column :live_collections, :last_run, :datetime
  end
end
