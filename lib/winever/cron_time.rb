module Winever
  class CronTime
    attr_accessor :string, :parts, :minute, :hour, :day, :month, :dow

    def initialize cron_time_string
      @string = cron_time_string

      @parts = Array.new(5, '')
      string_parts = cron_time_string.split(/ +/)
      @parts[0...string_parts.size] = string_parts

      @minute, @hour, @day, @month, @dow = @parts
    end

    def triggers
      # For now, we don't support anything other than specific time.
      # But it is possible to handle almost all cron schedule options in the task scheduler of Windows.
      # It doesn't help that win32-taskscheduler also seems to only support one trigger per task.

      return [] unless supported?
      trigger = {
          :start_year => Date.today.year,
          :start_month => Date.today.month,
          :start_day => Date.today.day,
          :start_hour => hour.to_i,
          :start_minute => minute.to_i,
          :trigger_type => Win32::TaskScheduler::TASK_TIME_TRIGGER_DAILY
      }

      [trigger]
    end

    def supported?
      unsupported_reason.nil?
    end

    def unsupported_reason
      return "Need 5 parts delimited by spaces" if parts.compact.reject(&:empty?).length != 5
      return "Only '*' is supported for day, month and day or week parts" if [day, month, dow].detect{|v| v != '*'}
      return "Only single number is supported for minute and hour parts" if [minute, hour].detect{|v| (v =~ /^\d+$/).nil? }
      nil
    end
  end
end