class User < ApplicationRecord
  has_many :articles
  validates :name, presence :true
  validates :password, presence :true, length: {minimum:8}
end
