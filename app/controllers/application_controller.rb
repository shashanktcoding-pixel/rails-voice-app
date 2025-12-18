class ApplicationController < ActionController::API
  before_action :authenticate_user!

  private

  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last

    unless token
      render json: { error: 'Unauthorized - No token provided' }, status: :unauthorized
      return
    end

    begin
      # Decode JWT token to get user ID
      # Note: In production, you should verify the token signature with Supabase
      payload = decode_token(token)
      @current_user_id = payload['sub']
    rescue StandardError => e
      render json: { error: "Unauthorized - Invalid token: #{e.message}" }, status: :unauthorized
    end
  end

  def decode_token(token)
    # Simple JWT decode without verification for now
    # In production, verify with Supabase's public key
    parts = token.split('.')
    payload = JSON.parse(Base64.decode64(parts[1]))
    payload
  rescue StandardError => e
    raise "Token decode failed: #{e.message}"
  end

  def current_user_id
    @current_user_id
  end
end
