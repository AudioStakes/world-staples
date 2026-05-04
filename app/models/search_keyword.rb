class SearchKeyword < ApplicationRecord
  include Taggable
  validates :keyword, presence: true
end
