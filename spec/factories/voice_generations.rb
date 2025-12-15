FactoryBot.define do
  factory :voice_generation do
    text { "Hello, this is a test voice generation." }
    status { "pending" }
    audio_file_path { nil }
    error_message { nil }

    trait :processing do
      status { "processing" }
    end

    trait :completed do
      status { "completed" }
      audio_file_path { "https://example.supabase.co/storage/v1/object/public/voice-generations/voice_123.mp3" }
    end

    trait :failed do
      status { "failed" }
      error_message { "ElevenLabs API error: 401 - Unauthorized" }
    end
  end
end
