FactoryBot.define do
  factory :voice_generation do
    text { "MyText" }
    status { "MyString" }
    audio_file_path { "MyString" }
    error_message { "MyText" }
  end
end
