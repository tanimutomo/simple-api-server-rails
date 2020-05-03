module JwtAuthenticator
  include Error
  require "jwt"

  SECRET_KEY = Rails.application.secrets.secret_key_base
  ALGORITHM = 'HS256'

  def jwt_authenticate
    if request.headers["Authorization"].blank?
      raise Error::BadRequestError.new("Cant't find token in header")
    end

    # Get token from header like below.
    # headers["Authorization"] = "Bearer <TOKEN>"
    encoded_token = request.headers["Authorization"].split("Bearer ").last
    # Decode token
    payload = decode(encoded_token)

    # Check requested user and url user
    if params[:id].to_i != payload["user_id"] and params[:user_id].to_i != payload["user_id"]
      raise Error::UnauthorizedError.new("No access permission")
    end

    # Get user from payload
    @current_user = User.find_by(id: payload["user_id"])
    if @current_user.blank?
      raise Error::NotFoundError.new("The requested user is not found")
    end

    @current_user
  end

  def encode(user_id)
    expires_in = 1.hour.from_now.to_i
    preload = {user_id: user_id, exp: expires_in}
    JWT.encode(preload, SECRET_KEY, ALGORITHM)
  end

  def decode(encoded_token)
    decoded_dwt = JWT.decode(encoded_token, SECRET_KEY, true, algorithm: ALGORITHM)
    decoded_dwt.first
  rescue 
    raise Error::UnauthorizedError.new("Token is expired")
  end
end