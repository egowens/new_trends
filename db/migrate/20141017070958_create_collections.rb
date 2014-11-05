class CreateCollections < ActiveRecord::Migration
  def change
    create_table :collections do |t|
      t.string :title
      t.datetime :published_at_min
      t.integer :collection_id

      t.timestamps
    end
  end
end
