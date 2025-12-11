class Rack::Attack
  # Throttle all requests by IP (60rpm per IP)
  throttle('req/ip', limit: 60, period: 1.minute) do |req|
    req.ip
  end

  # Throttle voice generation specifically (10 per IP per minute)
  throttle('voice_generation/ip', limit: 10, period: 1.minute) do |req|
    req.ip if req.path == '/generate_voice' && req.post?
  end

  # Custom response when throttled
  self.throttled_responder = lambda do |env|
    retry_after = env['rack.attack.match_data'][:period]
    [
      429,
      {'Content-Type' => 'application/json', 'Retry-After' => retry_after.to_s},
      [{error: 'Rate limit exceeded. Try again later.'}.to_json]
    ]
  end
end

# Enable rack-attack
Rails.application.config.middleware.use Rack::Attack
