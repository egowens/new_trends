class LiveCollection < ActiveRecord::Base
  validates :shop_url, presence: true
  validates :title, presence: true
  validates :time_number, presence: true
  validates :time_type, presence: true
end
