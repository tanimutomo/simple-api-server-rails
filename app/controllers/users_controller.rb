class UsersController < ApplicationController
  include Error
  include JwtAuthenticator

  before_action :jwt_authenticate, except: :create
  before_action :set_user, only: [:show, :update, :destroy]

  # GET /users/1
  def show
    render json: @user
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
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

    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.by_user_id(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:name, :password)
    end
end
