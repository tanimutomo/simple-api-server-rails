class Article < ApplicationRecord
  has_many :tags
  belongs_to :user
  validates :title, presence: true
  validates :content, presence: true

  # Scopes
  scope :by_article_id, ->(article_id) { find(article_id) }
  scope :by_user_id, ->(user_id) { where(user_id: user_id) }

  scope :all_of_user, ->(user_id) { by_user_id(user_id) }
  scope :one_of_user, ->(article_id, user_id) { by_user_id(user_id).by_article_id(article_id) }
end
