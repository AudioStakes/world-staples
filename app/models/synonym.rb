class Synonym < ApplicationRecord
  before_validation :normalize_fields

  validates :term, :normalized_term, presence: true
  validates :term, uniqueness: { scope: :locale }

  private

  def normalize_fields
    self.term = TextNormalizer.normalize(term)
    self.normalized_term = TextNormalizer.normalize(normalized_term)
  end
end
