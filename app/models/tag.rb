class Tag < ApplicationRecord
  belongs_to :article
  validates :name, presence: true
end
