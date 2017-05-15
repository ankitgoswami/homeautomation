namespace :hue do
  desc "Play music when the bathroom light turns on"

  task bathroom_music: :environment do

    PLAYLIST_URL = "https://open.spotify.com/user/125479996/playlist/2p6uCP5maPFydCn9CQxlVw"
    SPEAKER_NAME = "iLuv Syren"
    INTERNAL_SPEAKERS = "Internal Speakers"
    MUSIC_HOURS_WINDOW = [7, 23]
    ROOM_NAME = "Bathroom"
    NEXT_LIGHT_RANGE = (17500..30000)

    p "Bathroom will sing!"

    light = light_in_room(ROOM_NAME)
    sensor = sensor(Hue::LightSensor)

    player = SpotifyPlayer.new(PLAYLIST_URL, SPEAKER_NAME, INTERNAL_SPEAKERS)

    play_trigger = MusicTrigger.new(player, [true], :play, operating_hours: MUSIC_HOURS_WINDOW)
    pause_trigger = MusicTrigger.new(player, [false], :pause)
    next_trigger = MusicTrigger.new(player, NEXT_LIGHT_RANGE, :next, flip_range: true)

    light_monitor = DeviceMonitor.new(light, :on?, [play_trigger, pause_trigger])
    sensor_monitor = DeviceMonitor.new(sensor, :lightlevel, [next_trigger])

    light_monitor_thread = Thread.new { light_monitor.run }
    sensor_monitor_thread = Thread.new { sensor_monitor.run }

    light_monitor_thread.join
    sensor_monitor_thread.join
  end

  private

  def light_in_room(room_name)
    Hue::Client.new.lights.find{ |l| l.name.include?(room_name) }
  rescue
    nil
  end

  def sensor(type)
    Hue::Client.new.sensors.find{ |s| s.is_a?(type) }
  rescue
    nil
  end
end
