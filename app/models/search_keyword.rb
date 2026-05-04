class SearchKeyword < ApplicationRecord
  include Taggable

  before_validation :set_normalized_keyword

  validates :keyword, presence: true

  private

  def set_normalized_keyword
    self.normalized_keyword = TextNormalizer.normalize(keyword) if keyword.present?
  end
end
