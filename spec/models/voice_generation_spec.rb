require 'rails_helper'

RSpec.describe VoiceGeneration, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      voice_generation = build(:voice_generation)
      expect(voice_generation).to be_valid
    end

    it 'is not valid without text' do
      voice_generation = build(:voice_generation, text: nil)
      expect(voice_generation).not_to be_valid
      expect(voice_generation.errors[:text]).to include("can't be blank")
    end

    it 'is not valid with an invalid status' do
      voice_generation = build(:voice_generation)
      expect {
        voice_generation.status = 'invalid_status'
        voice_generation.valid?
      }.not_to raise_error
      expect(voice_generation).not_to be_valid
      expect(voice_generation.errors[:status]).to include("is not included in the list")
    end

    it 'is valid with pending status' do
      voice_generation = build(:voice_generation, status: 'pending')
      expect(voice_generation).to be_valid
    end

    it 'is valid with processing status' do
      voice_generation = build(:voice_generation, status: 'processing')
      expect(voice_generation).to be_valid
    end

    it 'is valid with completed status' do
      voice_generation = build(:voice_generation, status: 'completed')
      expect(voice_generation).to be_valid
    end

    it 'is valid with failed status' do
      voice_generation = build(:voice_generation, status: 'failed')
      expect(voice_generation).to be_valid
    end
  end

  describe 'callbacks' do
    it 'sets default status to pending on create' do
      voice_generation = VoiceGeneration.new(text: 'Test text')
      voice_generation.valid?
      expect(voice_generation.status).to eq('pending')
    end

    it 'does not override existing status on create' do
      voice_generation = VoiceGeneration.new(text: 'Test text', status: 'processing')
      voice_generation.valid?
      expect(voice_generation.status).to eq('processing')
    end
  end

  describe 'scopes' do
    let!(:pending_generation) { create(:voice_generation, status: 'pending') }
    let!(:processing_generation) { create(:voice_generation, :processing) }
    let!(:completed_generation) { create(:voice_generation, :completed) }
    let!(:failed_generation) { create(:voice_generation, :failed) }

    describe '.pending' do
      it 'returns only pending voice generations' do
        expect(VoiceGeneration.pending).to eq([pending_generation])
      end
    end

    describe '.processing' do
      it 'returns only processing voice generations' do
        expect(VoiceGeneration.processing).to eq([processing_generation])
      end
    end

    describe '.completed' do
      it 'returns only completed voice generations' do
        expect(VoiceGeneration.completed).to eq([completed_generation])
      end
    end

    describe '.failed' do
      it 'returns only failed voice generations' do
        expect(VoiceGeneration.failed).to eq([failed_generation])
      end
    end
  end

  describe '#audio_url' do
    it 'returns the audio_file_path for completed generation' do
      voice_generation = build(:voice_generation, :completed)
      expect(voice_generation.audio_url).to eq(voice_generation.audio_file_path)
    end

    it 'returns nil when audio_file_path is not set' do
      voice_generation = build(:voice_generation)
      expect(voice_generation.audio_url).to be_nil
    end
  end
end
