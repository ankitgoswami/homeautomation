class TimePlayer < AudioPlayer

  def initialize(on_speaker, off_speaker)
    super(on_speaker, off_speaker)
  end

  def speak
    return if invalid_output_device?

    system("date '+ It is %I:%M %p' | say")
  end
end
