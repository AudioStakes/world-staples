class StapleLevel < ApplicationRecord
  include Taggable
  validates :code, presence: true
end
