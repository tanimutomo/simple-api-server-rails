class ArticlesController < ApplicationController
  include Error
  include JwtAuthenticator

  before_action :jwt_authenticate, except: :create
  before_action :set_articles, only: [:index]
  before_action :set_article, only: [:show, :update, :destroy]

  # In /users/:user_id

  # GET /articles
  def index
    render json: @articles
  end

  # GET /articles/1
  def show
    render json: @article
  end

  # POST /articles
  def create
    @article = Article.new(article_params)

    if @article.save
      render json: @article, status: :created
    else
      render json: @article.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /articles/1
  def update
    if @article.update(article_params)
      render json: @article
    else
      render json: @article.errors, status: :unprocessable_entity
    end
  end

  # DELETE /articles/1
  def destroy
    if @article.destroy
      render json: @article, status: :ok
    else
      render json: @articles.errors, status: :unprocessable_entity
    end
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

  def set_articles
    @articles = Article.all_of_user(params[:user_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_article
    @article = Article.one_of_user(params[:id], params[:user_id])
  end

  # Only allow a trusted parameter "white list" through.
  def article_params
    params_ = params.require(:article).permit(:title, :content)
    params_['user_id'] = params[:user_id].to_i
    params_
  end
end
