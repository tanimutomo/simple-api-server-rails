class UsersController < ApplicationController
  include Error
  include JwtAuthenticator

  before_action :jwt_authenticate, except: :create

  # GET /users/1
  def show
    user = User.by_user(params[:id])
    render json: user, status: :ok
  end

  # POST /users
  def create
    user = User.new(requested)
    unless user.save
      raise Error::BadRequestError.new("A lack of required parameter for creating a new user")
    end

    render json: user, status: :created
  end

  # PATCH/PUT /users/1
  def update
    user = User.by_user(params[:id])
    if user.blank?
      raise Error::NotFoundError.new("Requested user is not existed")
    end

    unless user.update(requested_user)
      raise Error::BadRequestError.new("A lack of required parameter for creating a new user")
    end

    render json: user, status: :ok
  end

  # DELETE /users/1
  def destroy
    user = User.by_user(params[:id])
    if user.blank?
      raise Error::NotFoundError.new("Requested user is not existed")
    end

    user.destroy
  end

  rescue_from Error::UnauthorizedError do |e|
    render json: { message: e.message }, status: :unauthorized
  end
  rescue_from Error::BadRequestError do |e|
    render json: { message: e.message }, status: :bad_request
  end
  rescue_from Error::NotFoundError do |e|
    render json: { message: e.message }, status: :not_found
  end
  rescue_from Error::InternalServerError do |e|
    render json: { message: e.message }, status: :internal_server
  end

  private

  def requested_user
    params.require(:user).permit(:name, :password)
  end
end
