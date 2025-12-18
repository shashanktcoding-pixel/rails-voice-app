require 'rails_helper'

RSpec.describe ElevenLabsService do
  let(:api_key) { 'test_api_key_12345' }
  let(:voice_id) { 'test_voice_id' }
  let(:service) { described_class.new }
  let(:text) { 'Hello, this is a test.' }

  before do
    ENV['ELEVEN_LABS_API_KEY'] = api_key
    ENV['ELEVEN_LABS_VOICE_ID'] = voice_id
  end

  describe '#initialize' do
    it 'sets the API key from environment' do
      expect(service.instance_variable_get(:@api_key)).to eq(api_key)
    end

    it 'sets the voice ID from environment' do
      expect(service.instance_variable_get(:@voice_id)).to eq(voice_id)
    end

    it 'uses default voice ID when not set in environment' do
      ENV['ELEVEN_LABS_VOICE_ID'] = nil
      service = described_class.new
      expect(service.instance_variable_get(:@voice_id)).to eq('EXAVITQu4vr4xnSDxMaL')
    end
  end

  describe '#generate_speech' do
    let(:audio_data) { 'binary audio data' }
    let(:api_url) { "https://api.elevenlabs.io/v1/text-to-speech/#{voice_id}" }

    context 'when API call is successful' do
      before do
        stub_request(:post, api_url)
          .with(
            headers: {
              'Accept' => 'audio/mpeg',
              'Content-Type' => 'application/json',
              'xi-api-key' => api_key
            },
            body: {
              text: text,
              model_id: 'eleven_turbo_v2_5',
              voice_settings: {
                stability: 0.5,
                similarity_boost: 0.75
              }
            }.to_json
          )
          .to_return(status: 200, body: audio_data)
      end

      it 'returns the audio data' do
        result = service.generate_speech(text)
        expect(result).to eq(audio_data)
      end

      it 'makes a POST request to ElevenLabs API' do
        service.generate_speech(text)
        expect(WebMock).to have_requested(:post, api_url).once
      end
    end

    context 'when API call fails' do
      before do
        stub_request(:post, api_url)
          .to_return(status: 401, body: '{"error": "Unauthorized"}', headers: { 'Content-Type' => 'application/json' })
      end

      it 'raises an error with the API response details' do
        expect {
          service.generate_speech(text)
        }.to raise_error(/ElevenLabs API error: 401/)
      end
    end

    context 'when API returns 500 error' do
      before do
        stub_request(:post, api_url)
          .to_return(status: 500, body: 'Internal Server Error')
      end

      it 'raises an error' do
        expect {
          service.generate_speech(text)
        }.to raise_error(/ElevenLabs API error: 500/)
      end
    end

    context 'when API times out' do
      before do
        stub_request(:post, api_url).to_timeout
      end

      it 'raises a timeout error' do
        expect {
          service.generate_speech(text)
        }.to raise_error(Net::OpenTimeout)
      end
    end
  end
end
