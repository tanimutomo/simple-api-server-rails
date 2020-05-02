class Article < ApplicationRecord
  has_many :tags
  belongs_to :user
  validates :title, presence :true
  validates :content, presence :true
end
