class SearchTerm < ApplicationRecord
  belongs_to :staple
  validates :term, :normalized_term, :source_type, presence: true
end
