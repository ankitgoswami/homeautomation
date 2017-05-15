class SpotifyPlayer

  def initialize(playlist, on_speaker, off_speaker)
    @playlist = playlist
    @on_speaker = on_speaker
    @off_speaker = off_speaker
  end

  def play
    return if playing?

    set_audiodevice(@on_speaker)
    system("spotify play uri #{@playlist}")
  end

  def pause
    return unless playing?

    system("spotify pause")
    sleep(4)
    set_audiodevice(@off_speaker)
  end

  def next
    return unless playing?

    system("spotify next")
  end

  private

  def set_audiodevice(device_name)
    current_state = p `audiodevice output`
    return if current_state.include?(device_name)

    system("audiodevice output '#{device_name}'")
  end

  def playing?
    current_state = p `spotify status`
    current_state.include?("playing")
  end
end
