class Article < ApplicationRecord
  has_many :tags
  has_many :article_translations
  belongs_to :user

  # Scopes
  scope :by_article_id, ->(article_id) { find(article_id) }
  scope :by_user_id, ->(user_id) { where(user_id: user_id) }

  scope :all_by_user, ->(user_id) { by_user_id(user_id) }
  scope :by_article_user, ->(article_id, user_id) { by_user_id(user_id).by_article_id(article_id) }
end
