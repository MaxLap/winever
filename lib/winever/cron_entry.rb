module Winever
  class CronEntry
    attr_accessor :cron_time, :task_folder, :task_name, :working_directory, :parameters, :cron_line

    def self.from_cron_output cron_output, include_invalid=false
      entries = cron_output.split("\n").reject(&:empty?).map{|o| new(o)}
      entries = entries.select(&:valid?) unless include_invalid
      entries
    end

    def initialize(cron_line)
      @cron_line = cron_line
      @cron_parts = cron_line.split("|", 5)
      cron_time_string, @task_folder, @task_name, @working_directory, @parameters = @cron_parts
      @cron_time = Winever::CronTime.new(cron_time_string)
    end

    def triggers
      @cron_time.triggers
    end

    def valid?
      invalid_reason.nil?
    end

    def invalid_reason
      return "Doesn't match the Winever format" unless @cron_parts.length == 5
      return "Doesn't have a task_name specified" if @task_name.nil? || @task_name.empty?
      return "Problem with schedule: #{@cron_time.unsupported_reason}" unless @cron_time.supported?
      nil
    end

  end
end