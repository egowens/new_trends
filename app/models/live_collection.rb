class LiveCollection < ActiveRecord::Base
  validates :shop_url, presence: true
  validates :title, presence: true
  validates :created_after, presence: true
end
