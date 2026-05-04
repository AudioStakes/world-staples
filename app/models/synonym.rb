class Synonym < ApplicationRecord
  validates :term, :normalized_term, presence: true
  validates :term, uniqueness: { scope: :locale }
end
