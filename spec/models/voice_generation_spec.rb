require 'rails_helper'

RSpec.describe VoiceGeneration, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:voice_generation)).to be_valid
    end

    it 'requires text to be present' do
      voice_generation = build(:voice_generation, text: nil)
      expect(voice_generation).not_to be_valid
      expect(voice_generation.errors[:text]).to include("can't be blank")
    end

    it 'requires status to be in valid statuses' do
      voice_generation = build(:voice_generation, status: 'invalid_status')
      expect(voice_generation).not_to be_valid
      expect(voice_generation.errors[:status]).to include('is not included in the list')
    end
  end

  describe 'callbacks' do
    it 'defaults status to "pending" on new records before validation' do
      voice_generation = VoiceGeneration.new(text: 'A new voice generation.')
      voice_generation.valid?
      expect(voice_generation.status).to eq('pending')
    end

    it 'does not override status if it is provided' do
      voice_generation = VoiceGeneration.new(text: 'A new voice generation.', status: 'processing')
      voice_generation.valid?
      expect(voice_generation.status).to eq('processing')
    end
  end

  describe 'scopes' do
    let!(:pending_generation) { create(:voice_generation, status: 'pending') }
    let!(:processing_generation) { create(:voice_generation, status: 'processing') }
    let!(:completed_generation) { create(:voice_generation, :completed) }
    let!(:failed_generation) { create(:voice_generation, :failed) }

    it 'returns pending generations with the .pending scope' do
      expect(VoiceGeneration.pending).to include(pending_generation)
      expect(VoiceGeneration.pending).not_to include(processing_generation, completed_generation, failed_generation)
    end

    it 'returns processing generations with the .processing scope' do
      expect(VoiceGeneration.processing).to include(processing_generation)
      expect(VoiceGeneration.processing).not_to include(pending_generation, completed_generation, failed_generation)
    end

    it 'returns completed generations with the .completed scope' do
      expect(VoiceGeneration.completed).to include(completed_generation)
      expect(VoiceGeneration.completed).not_to include(pending_generation, processing_generation, failed_generation)
    end

    it 'returns failed generations with the .failed scope' do
      expect(VoiceGeneration.failed).to include(failed_generation)
      expect(VoiceGeneration.failed).not_to include(pending_generation, processing_generation, completed_generation)
    end
  end

  describe '#audio_url' do
    it 'returns the audio_file_path when set' do
      voice_generation = create(:voice_generation, :completed)
      expect(voice_generation.audio_url).to eq(voice_generation.audio_file_path)
    end

    it 'returns nil when audio_file_path is not set' do
      voice_generation = create(:voice_generation)
      expect(voice_generation.audio_url).to be_nil
    end
  end
end

