class StapleAlias < ApplicationRecord
  belongs_to :staple
  validates :name, presence: true

  before_validation :set_normalized_name

  private

  def set_normalized_name
    self.normalized_name = TextNormalizer.normalize(name)
  end
end
