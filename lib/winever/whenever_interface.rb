module Winever
  module WheneverInterface
    def self.run_from_winever?
      @run_from_winever || false
    end

    def self.remove_existing_tasks *names
      @existing_tasks_to_remove ||= []
      @existing_tasks_to_remove.concat(names.flatten)
    end

    def self.existing_tasks_to_remove
      @existing_tasks_to_remove ||= []
    end

    def self.raw_cron options={}
      # The output of whenever with the custom job_types and job_template.
      options[:file]       ||= 'config/schedule.rb'
      options[:cut]        ||= 0
      options[:identifier] ||= File.expand_path(options[:file])

      schedule = if options[:string]
                   options[:string]
                 elsif options[:file]
                   File.read(options[:file])
                 end

      # Prepending out own setup for the schedule to override the existing job_types and job_template.
      options[:string] = File.read(File.dirname(__FILE__)+"/setup_schedule.rb") + "\n" + schedule

      @run_from_winever = true
      output = Whenever.cron(options)
      @run_from_winever = false
      output
    end

    def self.valid_cron_entries options={}
      # Array of CronEntry containing only the entry that we support.
      Winever::CronEntry.from_cron_output(raw_cron(options))
    end

    def self.all_cron_entries options={}
      # Array of CronEntry containing only the entry that we support.
      Winever::CronEntry.from_cron_output(raw_cron(options), true)
    end

    def self.cron options={}
      # Content of a printable cron in internal Winever format. Also displays entry that are not handled and why.
      entries = all_cron_entries(options)
      valid_entries = entries.select(&:valid?)
      invalid_entries = entries.reject(&:valid?)


      output = "# Valid tasks for Winever in internal format:\n"
      if !valid_entries.empty?
        output << valid_entries.map(&:cron_line).join("\n\n")
      else
        output << "No valid entries"
      end
      output << "\n\n"

      if !invalid_entries.empty?
        output << "\n# Invalid entries for Winever in internal format:\n"
        invalid_entries.each do |invalid_entry|
          output << "# #{invalid_entry.invalid_reason}\n"
          output << "#{invalid_entry.cron_line}\n\n"
        end
      end

      if !existing_tasks_to_remove.empty?
        if existing_tasks_to_remove.size <= 15
          output << "\n# Additionnal task names that will be removed if they exist:\n"
          existing_tasks_to_remove.each do |path|
            output << "# - #{path}\n"
          end
        else
          output << "\n# Additionnal task names that will be removed if they exist:\n"
          output << "#  (More than #{15} task names, not displaying.)\n"
        end
        output << "\n"
      end
      output
    end
  end


end