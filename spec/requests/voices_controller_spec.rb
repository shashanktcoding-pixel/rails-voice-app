require 'rails_helper'

RSpec.describe "Voices API", type: :request do
  describe "POST /generate_voice" do
    let(:valid_params) { { text: "Hello, this is a test voice generation." } }
    let(:invalid_params) { { text: "" } }

    context "with valid parameters" do
      it "creates a new voice generation" do
        expect {
          post "/generate_voice", params: valid_params, headers: auth_headers
        }.to change(VoiceGeneration, :count).by(1)
      end

      it "returns status 202 accepted" do
        post "/generate_voice", params: valid_params, headers: auth_headers
        expect(response).to have_http_status(:accepted)
      end

      it "returns voice generation details" do
        post "/generate_voice", params: valid_params, headers: auth_headers
        json_response = JSON.parse(response.body)

        expect(json_response).to have_key("id")
        expect(json_response).to have_key("status")
        expect(json_response).to have_key("message")
        expect(json_response).to have_key("status_url")
        expect(json_response["status"]).to eq("pending")
        expect(json_response["message"]).to eq("Voice generation started")
      end

      it "enqueues a VoiceGenerationJob" do
        expect {
          post "/generate_voice", params: valid_params, headers: auth_headers
        }.to change(VoiceGenerationJob.jobs, :size).by(1)
      end

      it "returns correct status URL format" do
        post "/generate_voice", params: valid_params, headers: auth_headers
        json_response = JSON.parse(response.body)

        expect(json_response["status_url"]).to match(/\/voice_status\/\d+/)
      end
    end

    context "with invalid parameters" do
      it "does not create a voice generation" do
        expect {
          post "/generate_voice", params: invalid_params, headers: auth_headers
        }.not_to change(VoiceGeneration, :count)
      end

      it "returns status 422 unprocessable entity" do
        post "/generate_voice", params: invalid_params, headers: auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error messages" do
        post "/generate_voice", params: invalid_params, headers: auth_headers
        json_response = JSON.parse(response.body)

        expect(json_response).to have_key("errors")
        expect(json_response["errors"]).to be_an(Array)
        expect(json_response["errors"]).to include("Text can't be blank")
      end
    end

    context "without text parameter" do
      it "returns unprocessable entity status" do
        post "/generate_voice", params: {}, headers: auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /voice_status/:id" do
    context "when voice generation exists" do
      let!(:pending_generation) { create(:voice_generation, status: 'pending', supabase_user_id: test_user_id) }
      let!(:processing_generation) { create(:voice_generation, :processing, supabase_user_id: test_user_id) }
      let!(:completed_generation) { create(:voice_generation, :completed, supabase_user_id: test_user_id) }
      let!(:failed_generation) { create(:voice_generation, :failed, supabase_user_id: test_user_id) }

      it "returns pending status for pending generation" do
        get "/voice_status/#{pending_generation.id}", headers: auth_headers
        json_response = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(json_response["status"]).to eq("pending")
        expect(json_response["id"]).to eq(pending_generation.id)
        expect(json_response["text"]).to eq(pending_generation.text)
        expect(json_response).not_to have_key("audio_url")
        expect(json_response).not_to have_key("error")
      end

      it "returns processing status for processing generation" do
        get "/voice_status/#{processing_generation.id}", headers: auth_headers
        json_response = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(json_response["status"]).to eq("processing")
        expect(json_response).not_to have_key("audio_url")
        expect(json_response).not_to have_key("error")
      end

      it "returns completed status with audio URL" do
        get "/voice_status/#{completed_generation.id}", headers: auth_headers
        json_response = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(json_response["status"]).to eq("completed")
        expect(json_response["audio_url"]).to eq(completed_generation.audio_url)
        expect(json_response).not_to have_key("error")
      end

      it "returns failed status with error message" do
        get "/voice_status/#{failed_generation.id}", headers: auth_headers
        json_response = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(json_response["status"]).to eq("failed")
        expect(json_response["error"]).to eq(failed_generation.error_message)
        expect(json_response).not_to have_key("audio_url")
      end
    end

    context "when voice generation does not exist" do
      it "returns 404 not found" do
        get "/voice_status/99999", headers: auth_headers
        expect(response).to have_http_status(:not_found)
      end

      it "returns error message" do
        get "/voice_status/99999", headers: auth_headers
        json_response = JSON.parse(response.body)

        expect(json_response).to have_key("error")
        expect(json_response["error"]).to eq("Voice generation not found")
      end
    end
  end
end
