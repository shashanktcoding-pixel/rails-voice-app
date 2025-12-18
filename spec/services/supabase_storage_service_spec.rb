require 'rails_helper'

RSpec.describe SupabaseStorageService do
  let(:supabase_url) { 'https://test.supabase.co' }
  let(:supabase_key) { 'test_key' }
  let(:bucket_name) { 'test-bucket' }
  let(:service) { described_class.new }
  let(:filename) { 'voice_123_1234567890.mp3' }
  let(:audio_data) { 'binary audio data' }

  before do
    ENV['SUPABASE_URL'] = supabase_url
    ENV['SUPABASE_ANON_KEY'] = supabase_key
    ENV['SUPABASE_BUCKET_NAME'] = bucket_name
  end

  describe '#initialize' do
    it 'sets supabase_url from environment' do
      expect(service.instance_variable_get(:@supabase_url)).to eq(supabase_url)
    end

    it 'sets supabase_key from environment' do
      expect(service.instance_variable_get(:@supabase_key)).to eq(supabase_key)
    end

    it 'sets bucket_name from environment' do
      expect(service.instance_variable_get(:@bucket_name)).to eq(bucket_name)
    end

    it 'uses default bucket name when not set' do
      ENV['SUPABASE_BUCKET_NAME'] = nil
      service = described_class.new
      expect(service.instance_variable_get(:@bucket_name)).to eq('voice-generations')
    end
  end

  describe '#upload_file' do
    let(:upload_url) { "#{supabase_url}/storage/v1/object/#{bucket_name}/#{filename}" }
    let(:expected_public_url) { "#{supabase_url}/storage/v1/object/public/#{bucket_name}/#{filename}" }

    context 'when upload is successful' do
      before do
        stub_request(:post, upload_url)
          .with(
            headers: {
              'Authorization' => "Bearer #{supabase_key}",
              'Content-Type' => 'audio/mpeg',
              'apikey' => supabase_key
            },
            body: audio_data
          )
          .to_return(status: 200, body: '{"Key": "voice_123.mp3"}')
      end

      it 'returns the public URL' do
        result = service.upload_file(filename, audio_data)
        expect(result).to eq(expected_public_url)
      end

      it 'makes a POST request to Supabase' do
        service.upload_file(filename, audio_data)
        expect(WebMock).to have_requested(:post, upload_url).once
      end
    end

    context 'when upload fails' do
      before do
        stub_request(:post, upload_url)
          .to_return(status: 400, body: '{"error": "Invalid file"}', headers: { 'Content-Type' => 'application/json' })
      end

      it 'raises an error' do
        expect {
          service.upload_file(filename, audio_data)
        }.to raise_error(/Supabase upload error: 400/)
      end
    end
  end

  describe '#get_public_url' do
    it 'returns the correct public URL' do
      expected_url = "#{supabase_url}/storage/v1/object/public/#{bucket_name}/#{filename}"
      expect(service.get_public_url(filename)).to eq(expected_url)
    end
  end

  describe '#delete_file' do
    let(:delete_url) { "#{supabase_url}/storage/v1/object/#{bucket_name}/#{filename}" }

    context 'when deletion is successful' do
      before do
        stub_request(:delete, delete_url)
          .to_return(status: 200, body: '{"message": "deleted"}')
      end

      it 'returns true' do
        expect(service.delete_file(filename)).to be true
      end
    end

    context 'when deletion fails' do
      before do
        stub_request(:delete, delete_url)
          .to_return(status: 404, body: '{"error": "Not found"}')
      end

      it 'returns false' do
        expect(service.delete_file(filename)).to be false
      end
    end
  end
end
