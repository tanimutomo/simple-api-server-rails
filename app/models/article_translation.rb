class ArticleTranslation < ApplicationRecord
  belongs_to :article

  validates :title, presence: true
  validates :content, presence: true
  validates :locale, presence: true

  # Scopes
  scope :by_article_id, ->(article_id) { where(article_id: article_id) }
  scope :by_locale, ->(locale) { where(locale: locale) }

  scope :all_by_article, ->(article_id) { by_article_id(article_id) }
  scope :all_by_articles, ->(article_ids) { by_article_id(article_ids) }
  scope :by_article_locale, ->(article_id, locale) { by_article_id(article_id).by_locale(locale) }
end
