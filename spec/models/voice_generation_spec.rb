require 'rails_helper'

RSpec.describe VoiceGeneration, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:voice_generation)).to be_valid
    end

    it { is_expected.to validate_presence_of(:text) }

    it { is_expected.to validate_inclusion_of(:status).in_array(VoiceGeneration::STATUSES) }
  end

  describe 'callbacks' do
    it 'defaults status to "pending" on new records' do
      voice_generation = VoiceGeneration.new(text: 'A new voice generation.')
      expect(voice_generation.status).to eq('pending')
    end

    it 'does not override status if it is provided' do
      voice_generation = VoiceGeneration.new(text: 'A new voice generation.', status: 'processing')
      expect(voice_generation.status).to eq('processing')
    end
  end

  describe 'scopes' do
    let!(:pending_generation) { create(:voice_generation, status: 'pending') }
    let!(:processing_generation) { create(:voice_generation, status: 'processing') }
    let!(:completed_generation) { create(:voice_generation, :completed) }
    let!(:failed_generation) { create(:voice_generation, :failed) }

    it 'returns pending generations with the .pending scope' do
      expect(VoiceGeneration.pending).to contain_exactly(pending_generation)
    end

    it 'returns processing generations with the .processing scope' do
      expect(VoiceGeneration.processing).to contain_exactly(processing_generation)
    end

    it 'returns completed generations with the .completed scope' do
      expect(VoiceGeneration.completed).to contain_exactly(completed_generation)
    end

    it 'returns failed generations with the .failed scope' do
      expect(VoiceGeneration.failed).to contain_exactly(failed_generation)
    end
  end
end

