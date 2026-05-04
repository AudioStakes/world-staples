class Shape < ApplicationRecord
  include Taggable
  validates :name_en, presence: true
end
