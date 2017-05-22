class TimeTrigger < Trigger

  def initialize(time_player, action, operating_hours: nil)
    @player = time_player
    @action = action
    @operating_hours = operating_hours
  end

  def match?(value)
    operating_hours?
  end

  def execute!
    @player.send(@action)
  end

  private

  def operating_hours?
    @operating_hours.nil? || Time.now.hour.between?(*@operating_hours)
  end
end
