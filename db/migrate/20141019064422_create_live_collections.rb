class CreateLiveCollections < ActiveRecord::Migration
  def change
    create_table :live_collections do |t|
      t.string :shop_url
      t.string :title
      t.integer :time_number
      t.string :created_after

      t.timestamps
    end
  end
end
