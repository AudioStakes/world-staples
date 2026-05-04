class Tagging < ApplicationRecord
  ALLOWED_TAGGABLE_TYPES = %w[
    IngredientFamily Ingredient Form Shape ProcessingMethod CookingMethod Texture
    Region CountryArea ServingStyle StapleLevel SearchKeyword
  ].freeze

  belongs_to :staple
  belongs_to :taggable, polymorphic: true, optional: true

  validates :staple, presence: true
  validates :taggable_type, inclusion: { in: ALLOWED_TAGGABLE_TYPES }
  validates :taggable_id, presence: true, uniqueness: { scope: %i[staple_id taggable_type] }

  validate :taggable_record_exists

  private

  def taggable_record_exists
    return unless ALLOWED_TAGGABLE_TYPES.include?(taggable_type)

    # Polymorphic associations cannot have strict DB foreign keys for every possible table.
    errors.add(:taggable_id, "must reference an existing record") unless taggable_type.constantize.exists?(taggable_id)
  end
end
