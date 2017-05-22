class SpotifyPlayer < AudioPlayer

  def initialize(playlist, on_speaker, off_speaker)
    @playlist = playlist
    super(on_speaker, off_speaker)
  end

  def play
    return if playing? || invalid_output_device?

    set_audiodevice(@on_speaker)
    system("spotify play uri #{@playlist}")
  end

  def pause
    return if !playing? || invalid_output_device?

    system("spotify pause")
    sleep(4)
    set_audiodevice(@off_speaker)
  end

  def next
    return if !playing? || invalid_output_device?

    system("spotify next")
  end

  private

  def playing?
    current_state = p `spotify status`
    current_state.include?("playing")
  end
end
