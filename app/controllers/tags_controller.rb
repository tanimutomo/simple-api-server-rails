class TagsController < ApplicationController
  include Error
  include JwtAuthenticator

  before_action :jwt_authenticate, except: :create
  before_action :set_user_tags, only: [:index_user]
  before_action :set_article_tags, only: [:index_article]
  before_action :set_tag, only: [:destroy]

  # GET /user/:user_id/tags
  def index_user
    render json: @tags
  end

  # GET /users/:user_id/articles/:article_id/tags
  def index_article
    render json: @tags
  end

  # POST /users/.../:article_id/tags
  def create
    @tag = Tag.new(tag_params)

    if @tag.save
      render json: @tag, status: :created
    else
      render json: @tag.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/.../:article_id/tags/1
  def destroy
    if @tag.destroy
      render json: @article, status: :ok
    else
      render json: @article.errors, status: :unprocessable_entity
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

  def set_user_tags
    @tags = Tag.all_of_user(params[:user_id])
  end

  def set_article_tags
    @tags = Tag.all_of_article(params[:article_id], params[:user_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_tag
    @tag = Tag.one_of_article(params[:id, params[:article_id], params[:user_id]])
  end

  # Only allow a trusted parameter "white list" through.
  def tag_params
    params_ = params.require(:tag).permit(:name, :article_id)
    params_["user_id"] = params[:user_id].to_i
    params_["article_id"] = params[:article_id].to_i
    params_
  end
end
