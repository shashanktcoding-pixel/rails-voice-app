require 'rails_helper'

RSpec.describe VoiceGenerationJob, type: :job do
  let(:voice_generation) { create(:voice_generation) }
  let(:audio_data) { 'binary audio data' }
  let(:audio_url) { 'https://test.supabase.co/storage/v1/object/public/test-bucket/voice_123.mp3' }
  let(:eleven_labs_service) { instance_double(ElevenLabsService) }
  let(:storage_service) { instance_double(SupabaseStorageService) }

  before do
    allow(ElevenLabsService).to receive(:new).and_return(eleven_labs_service)
    allow(SupabaseStorageService).to receive(:new).and_return(storage_service)
  end

  describe '#perform' do
    context 'when generation is successful' do
      before do
        allow(eleven_labs_service).to receive(:generate_speech).with(voice_generation.text).and_return(audio_data)
        allow(storage_service).to receive(:upload_file).and_return(audio_url)
      end

      it 'updates status to processing' do
        described_class.new.perform(voice_generation.id)
        voice_generation.reload
        expect(voice_generation.status).to eq('completed')
      end

      it 'generates speech using ElevenLabsService' do
        described_class.new.perform(voice_generation.id)
        expect(eleven_labs_service).to have_received(:generate_speech).with(voice_generation.text)
      end

      it 'uploads audio using SupabaseStorageService' do
        described_class.new.perform(voice_generation.id)
        expect(storage_service).to have_received(:upload_file).with(anything, audio_data)
      end

      it 'updates status to completed and stores audio URL' do
        described_class.new.perform(voice_generation.id)
        voice_generation.reload
        expect(voice_generation.status).to eq('completed')
        expect(voice_generation.audio_file_path).to eq(audio_url)
      end
    end

    context 'when generation fails' do
      let(:error_message) { 'ElevenLabs API error' }

      before do
        allow(eleven_labs_service).to receive(:generate_speech).and_raise(StandardError, error_message)
      end

      it 'updates status to failed' do
        expect {
          described_class.new.perform(voice_generation.id)
        }.to raise_error(StandardError)

        voice_generation.reload
        expect(voice_generation.status).to eq('failed')
      end

      it 'stores the error message' do
        expect {
          described_class.new.perform(voice_generation.id)
        }.to raise_error(StandardError)

        voice_generation.reload
        expect(voice_generation.error_message).to eq(error_message)
      end

      it 're-raises the error' do
        expect {
          described_class.new.perform(voice_generation.id)
        }.to raise_error(StandardError, error_message)
      end
    end

    context 'when voice generation does not exist' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          described_class.new.perform(999999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
