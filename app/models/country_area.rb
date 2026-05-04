class CountryArea < ApplicationRecord
  include Taggable
  belongs_to :region, optional: true
  validates :name_en, presence: true
end
