class AudioPlayer

  def initialize(on_speaker, off_speaker)
    @on_speaker = on_speaker
    @off_speaker = off_speaker
  end

  private

  def set_audiodevice(device_name)
    current_state = p `audiodevice output`
    return if current_state.include?(device_name)

    system("audiodevice output '#{device_name}'")
  end

  def invalid_output_device?
    current_state = p `audiodevice output`
    [@on_speaker, @off_speaker].none? { |speaker| current_state.include?(speaker) }
  end
end
