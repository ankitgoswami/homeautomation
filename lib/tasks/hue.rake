namespace :hue do
  desc "Play music when the bathroom light turns on"

  task bathroom_music: :environment do

    PLAYLIST_URL = "https://open.spotify.com/user/125479996/playlist/2p6uCP5maPFydCn9CQxlVw"
    SPEAKER_NAME = "iLuv Syren"
    INTERNAL_SPEAKERS = "Internal Speakers"
    MUSIC_HOURS_WINDOW = [7, 23]
    TIME_HOURS_WINDOW = [9,9]
    ROOM_NAME = "Bathroom"
    NEXT_LIGHT_RANGE = (17500..30000)

    p "Bathroom will sing!"

    begin
      light = light_in_room(ROOM_NAME)
      sensor = sensor(Hue::LightSensor)

      player = SpotifyPlayer.new(PLAYLIST_URL, SPEAKER_NAME, INTERNAL_SPEAKERS)
      time_player = TimePlayer.new(SPEAKER_NAME, INTERNAL_SPEAKERS)

      play_trigger = MusicTrigger.new(player, [true], :play, operating_hours: MUSIC_HOURS_WINDOW)
      pause_trigger = MusicTrigger.new(player, [false], :pause)
      next_trigger = MusicTrigger.new(player, NEXT_LIGHT_RANGE, :next, flip_range: true)
      time_trigger = TimeTrigger.new(time_player, :speak, operating_hours: TIME_HOURS_WINDOW)

      monitors = [
        StateMonitor.new(light, :on?, [play_trigger, pause_trigger]),
        StateMonitor.new(sensor, :lightlevel, [next_trigger]),
        StateMonitor.new(Time, :now, [time_trigger], check_interval: 10.minutes.to_i)
      ]

      monitor_threads = monitors.map { |monitor| Thread.new { monitor.run } }

      monitor_threads.each { |thread| thread.join }
    rescue SystemExit, Interrupt => e
      p e.message
      monitor_threads.each { |t| Thread.kill t }
      player.pause
    end
  end

  private

  def light_in_room(room_name)
    Hue::Client.new.lights.find{ |l| l.name.include?(room_name) }
  end

  def sensor(type)
    Hue::Client.new.sensors.find{ |s| s.is_a?(type) }
  end
end
