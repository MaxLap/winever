module Winever
  class CronEntry
    attr_accessor :cron_time, :task_folder, :task_name, :working_directory, :parameters, :cron_line

    def self.from_cron_output cron_output, include_invalid=false
      entries = cron_output.split("\n").select(&:present?).map{|o| new(o)}
      entries = entries.select(&:valid?) unless include_invalid
      entries
    end

    def triggers
      # For now, we don't support anything other than specific time.
      # But it is possible to handle almost all cron schedule options in the task scheduler of Windows.
      # It doesn't help that win32-taskscheduler also seems to only support one trigger per task.
      return [] unless valid_triggers?

      cron_minute, cron_hour, cron_day, cron_month, cron_dow = @cron_time_parts
      trigger = {
          :start_year => Date.today.year,
          :start_month => Date.today.month,
          :start_day => Date.today.day,
          :start_hour => cron_hour.to_i,
          :start_minute => cron_minute.to_i,
          :trigger_type => Win32::TaskScheduler::TASK_TIME_TRIGGER_DAILY
      }

      [trigger]
    end

    def initialize(cron_line)
      @cron_line = cron_line
      @cron_parts = cron_line.split("|", 5)
      @cron_time, @task_folder, @task_name, @working_directory, @parameters = @cron_parts
      @cron_time_parts = @cron_time.split(/ +/)
    end

    def valid?
      invalid_reason.nil?
    end

    def valid_triggers?
      return false if @cron_time_parts.length < 5
      cron_minute, cron_hour, cron_day, cron_month, cron_dow = @cron_time_parts

      return false if [cron_day, cron_month, cron_dow].detect{|v| v != '*'}
      return false if [cron_minute, cron_hour].detect{|v| (v =~ /^\d+$/).nil? }

      true
    end

    def invalid_reason
      return "Doesn't match the Winever format" unless @cron_parts.length == 5
      return "Doesn't have a task_name specified" unless @task_name.present?
      return "The schedule is either invalid or not supported" unless valid_triggers?
      nil
    end
  end
end