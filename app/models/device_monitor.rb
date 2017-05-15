class DeviceMonitor

  def initialize(device, property, triggers, check_interval: 2)
    @device = device
    @property = property
    @triggers = triggers
    @check_interval = check_interval
  end

  def run
    loop do
      sleep(@check_interval)
      @device.refresh

      device_value = @device.send(@property)

      @triggers.each do |trigger|
        trigger.execute! if trigger.match?(device_value)
      end
    end
  end
end
