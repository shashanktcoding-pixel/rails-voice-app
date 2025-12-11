class SupabaseStorageService
  include HTTParty

  def initialize
    @supabase_url = ENV['SUPABASE_URL']
    @supabase_key = ENV['SUPABASE_ANON_KEY']
    @bucket_name = ENV['SUPABASE_BUCKET_NAME'] || 'voice-generations'
  end

  def upload_file(file_path, audio_data)
    filename = File.basename(file_path)

    Rails.logger.info "Uploading to Supabase: #{@bucket_name}/#{filename}"

    response = self.class.post(
      "#{@supabase_url}/storage/v1/object/#{@bucket_name}/#{filename}",
      headers: headers,
      body: audio_data
    )

    Rails.logger.info "Supabase upload response: #{response.code}"

    if response.success?
      get_public_url(filename)
    else
      error_message = response.parsed_response.dig('error') || response.message
      raise "Supabase upload error: #{response.code} - #{error_message}"
    end
  end

  def get_public_url(filename)
    "#{@supabase_url}/storage/v1/object/public/#{@bucket_name}/#{filename}"
  end

  def delete_file(filename)
    response = self.class.delete(
      "#{@supabase_url}/storage/v1/object/#{@bucket_name}/#{filename}",
      headers: headers
    )

    unless response.success?
      Rails.logger.error "Failed to delete file from Supabase: #{response.code}"
    end

    response.success?
  end

  private

  def headers
    {
      'Authorization' => "Bearer #{@supabase_key}",
      'Content-Type' => 'audio/mpeg',
      'apikey' => @supabase_key
    }
  end
end
