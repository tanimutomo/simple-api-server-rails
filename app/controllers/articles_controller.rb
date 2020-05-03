class ArticlesController < ApplicationController
  include Error
  include JwtAuthenticator

  before_action :jwt_authenticate, except: :create

  # In /users/:user_id

  # GET /articles
  def index
    # Get articles of a user
    articles = Article.all_by_user(params[:user_id])
    unless articles.present?
      render json: [], status: :ok
      return
    end

    # Extract article ids
    article_ids = []
    articles.each do |article|
      article_ids.push(article[:id])
    end

    # Get article translations of all articles
    article_translations = ArticleTranslation.all_by_articles(article_ids)

    render json: { article: articles, article_translation: article_translations }, status: :ok
  end

  # GET /articles/1
  def show
    # Get article
    article = Article.by_article_user(params[:id], params[:user_id])
    unless article.present?
      raise Error::NotFoundError.new(article.errors)
    end

    # Get article translations
    article_translations = ArticleTranslation.all_by_article(article[:id])

    render json: { article: article, article_translation: article_translations }, status: :ok
  end

  # POST /articles
  def create
    # Save to article
    article = Article.new(requested_article)
    unless article.save
      raise Error::BadRequestError.new(article.errors)
    end

    # Save to article translation
    article_translation = ArticleTranslation.new(requested_article_translation(article[:id]))
    unless article_translation.save
      article.destroy
      raise Error::BadRequestError.new(article.errors)
    end

    render json: { article: article, article_translation: article_translation }, status: :created
  end

  # PUT /articles/1
  # Update article or Add new locale's post
  def update
    # Check the requested article is exists
    article = Article.by_article_user(params[:id], params[:user_id])
    unless article.present?
      raise Error::NotFoundError.new(article.errors)
    end

    # Check the requested id and locale's article is exists
    article_translation = ArticleTranslation.by_article_locale(article[:id], params[:locale])
    if article_translation.present?
      # if exists, update post
      unless article_translation.update(requested_article_translation(article[:id]))
        raise BadRequestError(article_translation.errors)
      end
    else
      # if not exists create new post
      article_translation = ArticleTranslation.new(requested_article_translation(article[:id]))
      unless article_translation.save
        raise BadRequestError(article_translation.errors)
      end
    end

    render json: { article: article, article_translation: article_translation }, status: :ok
  end

  # DELETE /articles/1
  def destroy
    # Check the requested article is exists
    article = Article.by_article_user(params[:id], params[:user_id])
    unless article.present?
      raise Error::NotFoundError.new(article.errors)
    end

    # Delete all article and its translations
    article_translations = ArticleTranslation.all_by_article(params[:id])
    if article_translations.present?
      article.destroy
      article_translations.each do |article_translation|
        article_translation.destroy
      end
    end
    render json: { article: article, article_translations: article_translations }, status: :ok
  end

  rescue_from Error::UnauthorizedError do |e|
    render json: { message: e.message }, status: :unauthorized
  end
  rescue_from Error::BadRequestError do |e|
    render json: { message: e.message }, status: :bad_request
  end
  rescue_from Error::NotFoundError, ActiveRecord::RecordNotFound do |e|
    render json: { message: e.message }, status: :not_found
  end
  rescue_from Error::InternalServerError do |e|
    render json: { message: e.message }, status: :internal_server
  end

  private

  # Only allow a trusted parameter "white list" through.
  def requested_article
    { user_id: params[:user_id].to_i }
  end

  def requested_article_translation(article_id)
    {
      article_id: article_id,
      title: params[:title],
      content: params[:content],
      locale: params[:locale]
    }
  end
end
