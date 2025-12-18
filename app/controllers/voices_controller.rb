class VoicesController < ApplicationController
  def index
    voice_generations = VoiceGeneration
      .where(supabase_user_id: current_user_id)
      .order(created_at: :desc)

    render json: voice_generations.map { |vg|
      {
        id: vg.id,
        text: vg.text,
        status: vg.status,
        audio_url: vg.audio_url,
        created_at: vg.created_at,
        updated_at: vg.updated_at
      }
    }
  end

  def generate
    voice_generation = VoiceGeneration.new(
      text: params[:text],
      supabase_user_id: current_user_id
    )

    if voice_generation.save
      VoiceGenerationJob.perform_async(voice_generation.id)

      render json: {
        id: voice_generation.id,
        status: voice_generation.status,
        message: "Voice generation started",
        status_url: "#{request.base_url}/voice_status/#{voice_generation.id}"
      }, status: :accepted
    else
      render json: {
        errors: voice_generation.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def status
    # Only allow users to check status of their own voice generations
    voice_generation = VoiceGeneration.find_by!(
      id: params[:id],
      supabase_user_id: current_user_id
    )

    response_data = {
      id: voice_generation.id,
      status: voice_generation.status,
      text: voice_generation.text
    }

    if voice_generation.status == 'completed'
      response_data[:audio_url] = voice_generation.audio_url
    elsif voice_generation.status == 'failed'
      response_data[:error] = voice_generation.error_message
    end

    render json: response_data
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Voice generation not found" }, status: :not_found
  end
end
