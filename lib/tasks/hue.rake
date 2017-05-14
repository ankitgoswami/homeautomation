namespace :hue do
  desc "Play music when the bathroom light turns on"

  task bathroom_music: :environment do

    OFF_STATE = false
    ON_STATE = true
    PLAYLIST_URL = "https://open.spotify.com/user/125479996/playlist/2p6uCP5maPFydCn9CQxlVw"
    SPEAKER_NAME = "iLuv Syren"
    INTERNAL_SPEAKERS = "Internal Speakers"

    prev_state = OFF_STATE

    p "Bathroom will sing!"

    bathroom_light = light_in_room("Bathroom")

    loop do
      sleep 2
      bathroom_light.refresh
      new_state = light_state(light_in_room("Bathroom"))
      # p "#{Time.now} Bathroom light state - #{new_state}"
      trigger_spotify!(new_state) if trigger?(new_state, prev_state)
      prev_state = new_state
    end
  end

  def light_in_room(room_name)
    Hue::Client.new.lights.find{ |l| l.name.include?(room_name) }
  rescue
    nil
  end

  def light_state(light)
    light.try(:on?) ? ON_STATE : OFF_STATE
  end

  def trigger?(new_state, prev_state)
    (Time.now.hour.between?(7,23) || new_state == OFF_STATE) && new_state != prev_state
  end

  def trigger_spotify!(state)
    if state == ON_STATE
      set_audiodevice(SPEAKER_NAME)
      system("spotify play uri #{PLAYLIST_URL}")
    else
      system("spotify pause")
      sleep 1
      set_audiodevice(INTERNAL_SPEAKERS)
    end
  end

  def set_audiodevice(device_name)
    current_state = p `audiodevice output`
    return if current_state.include?(device_name)

    system("audiodevice output '#{device_name}'")
  end
end
