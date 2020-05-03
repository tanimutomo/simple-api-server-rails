class Tag < ApplicationRecord
  belongs_to :articles
  belongs_to :user
  validates :name, presence: true

  # Scopes
  scope :by_tag_id, ->(tag_id) { find(tag_id) }
  scope :by_article_id, ->(article_id) { where(article_id: article_id) }
  scope :by_user_id, ->(user_id) { where(user_id: user_id) }

  scope :all_by_user, ->(user_id) { by_user_id(user_id) }
  scope :all_by_article_user, ->(article_id, user_id) { by_user_id(user_id).by_article_id(article_id) }
  scope :by_article, ->(tag_id, article_id, user_id) { by_user_id(user_id).by_article_id(article_id).by_tag_id(tag_id) }
end
