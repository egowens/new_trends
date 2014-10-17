class Collection < ActiveRecord::Base
  validates :title, presence: true
  validates :published_min, presence: true
end
