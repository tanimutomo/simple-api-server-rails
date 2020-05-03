class TagsController < ApplicationController
  include Error
  include JwtAuthenticator

  before_action :jwt_authenticate, except: :create

  # GET /user/:user_id/tags
  def index_user
    tags = Tag.all_by_user(params[:user_id])
    render json: tags, status: :ok
  end

  # GET /users/:user_id/articles/:article_id/tags
  def index_article
    tags = Tag.all_by_article_user(params[:article_id], params[:user_id])
    render json: tags, status: :ok
  end

  # POST /users/.../:article_id/tags
  def create
    tag = Tag.new(requested_tag)
    unless tag.save
      raise Error::BadRequestError.new("A lack of required parameter for tag")
    end
    render json: tag, status: :created
  end

  # DELETE /users/.../:article_id/tags/1
  def destroy
    tag = Tag.by_article(params[:id], params[:article_id], params[:user_id])
    if tag.blank?
      raise Error::NotFoundError.new("Requested tag is not existed")
    end
    tag.destroy
    render json: tag, status: :ok
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

  def requested_tag
    tag = params.require(:tag).permit(:name, :article_id)
    tag["user_id"] = params[:user_id].to_i
    tag["article_id"] = params[:article_id].to_i
    tag
  end
end
