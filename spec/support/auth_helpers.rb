module AuthHelpers
  def test_user_id
    'test-user-123'
  end

  def auth_headers
    token = create_test_token(test_user_id)
    { 'Authorization' => "Bearer #{token}" }
  end

  def create_test_token(user_id)
    # Create a simple JWT-like token for testing
    # Format: header.payload.signature (we only need payload for the current implementation)
    header = Base64.encode64({ alg: 'HS256', typ: 'JWT' }.to_json).gsub("\n", '')
    payload = Base64.encode64({ sub: user_id, exp: Time.now.to_i + 3600 }.to_json).gsub("\n", '')
    signature = 'test-signature'

    "#{header}.#{payload}.#{signature}"
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
