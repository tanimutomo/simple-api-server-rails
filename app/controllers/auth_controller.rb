class AuthController < ApplicationController
  include Error
  include JwtAuthenticator

  # POST /auth/login
  def login 
    # Get User based on login ID
    @current_user = User.find_by(id: params[:id])
    # Authenticate by password
    if @current_user.password == params[:password]
      # Generate jwt
      jwt_token = encode(@current_user.id)
      # Set token to response header
      response.headers["X-authentication-Token"] = jwt_token
      # Return response
      render json: { token: jwt_token }, status: :ok
    else
      raise Error::UnauthorizedError.new("Incorrect password")
    end
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
end
