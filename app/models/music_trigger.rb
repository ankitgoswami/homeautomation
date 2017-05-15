class MusicTrigger < Trigger

  def initialize(player, trigger_range, action, flip_range: false, operating_hours: nil)
    @player = player
    @trigger_range = trigger_range
    @action = action
    @flip_range = flip_range
    @operating_hours = operating_hours
    @check_inclusion = true
  end

  def match?(value)
    return unless operating_hours?
    if @check_inclusion
      @trigger_range.include?(value)
    else
      @trigger_range.exclude?(value)
    end
  end

  def execute!
    @player.send(@action)

    @check_inclusion = !@check_inclusion if @flip_range
  end

  private

  def operating_hours?
    @operating_hours.nil? || Time.now.hour.between?(*@operating_hours)
  end
end
