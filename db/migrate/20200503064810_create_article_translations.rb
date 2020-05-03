class CreateArticleTranslations < ActiveRecord::Migration[6.0]
  def change
    create_table :article_translations do |t|
      t.string :title
      t.text :content
      t.integer :article_id

      t.timestamps
    end
  end
end
