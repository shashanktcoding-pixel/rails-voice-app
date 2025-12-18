class AddUserIdToVoiceGenerations < ActiveRecord::Migration[7.1]
  def change
    add_column :voice_generations, :supabase_user_id, :string
    add_index :voice_generations, :supabase_user_id
  end
end
