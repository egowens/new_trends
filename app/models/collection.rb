class Collection < ActiveRecord::Base
  validates :title, presence: true
  validates :published_at_min, presence: true
end
