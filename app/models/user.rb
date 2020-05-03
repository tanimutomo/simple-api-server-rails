# frozen_string_literal: true

class User < ApplicationRecord
  has_many :articles
  validates :name, presence: true
  validates :password, presence: true, length: { minimum: 8 }

  # Scopes
  scope :by_user, ->(user_id) { find(user_id) }
end
