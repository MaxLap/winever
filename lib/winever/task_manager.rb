module Winever
  class TaskManager
    def self.has_task_scheduler?
      return @has_task_scheduler unless @has_task_scheduler.nil?
      begin
        require 'win32/taskscheduler'
        @has_task_scheduler = true
      rescue LoadError => e
        @has_task_scheduler = false
      end
      @has_task_scheduler
    end

    def has_task_scheduler?
      self.class.has_task_scheduler?
    end

    def self.clear_tasks options={}
      new(options).clear_tasks_except
    end

    def self.update_tasks options={}
      new(options).update_tasks
    end

    def initialize options={}
      if !has_task_scheduler?
        raise "Cannot use win32/taskscheduler on this system. Are you on windows?"
      end

      @options = options
    end

    def password
      return @password.presence if @password
      require 'highline/import'
      prompt = <<-PRMP.gsub(/^ +/, '')
        To setup tasks correctly, the password of the current user account is needed.
        You can leave it empty, but without the password, the task will only be run the user is logged on and will open a black
        console window while running.
        You can manually go edit the scheduled task to add the password manually if you prefer not to give it to Winever, but you will need to go do that every time you edit the tasks through Winever, for each task.
        Enter the password of the current user (or just press enter to skip):
      PRMP

      pw = ask(prompt){|q| q.echo = false}
      while pw && !pw.empty? && !validate_password(pw)
        prompt = <<-PRMP.gsub(/^ +/, '')
          Invalid password entered.
          Enter the password of the current user (or just press enter to skip):
        PRMP
        pw = ask(prompt){|q| q.echo = false}
      end


      #TODO get the password somehow.
      # require File.expand_path('../../extensions/password', __FILE__)
      # password = Password.ask("Enter password for current user account of the machine to setup tasks: ")
      # validate_password(password)

      @password = pw
      pw.presence
    end

    def create_tasks
      cron_entries = Winever::WheneverInterface.valid_cron_entries(@options)

      created_task_names = []
      cron_entries.each do |cron_entry|
        created_task_names << create_task(cron_entry)
      end
      created_task_names
    end

    def update_tasks
      task_names = create_tasks
      clear_tasks_except(task_names)
    end

    def clear_tasks_except keep_tasks=[]
      ts = Win32::TaskScheduler.new
      task_names = ts.tasks.select{|tn| tn.end_with?('.' + identifier)}
      task_names.concat(Winever::WheneverInterface::existing_tasks_to_remove)

      task_names = task_names.reject{|tn| keep_tasks.include?(tn)}

      task_names.each{|tn| ts.delete(tn) if ts.exists?(tn)}
    end

    def create_task cron_entry
      task_name = generate_task_name(cron_entry.task_name)

      # Replacing the /dev/null by NUL
      parameters = cron_entry.parameters.gsub(/([\s'"])\/dev\/null([\s'"])/, '\1NUL\2')

      pw = password
      trigger = cron_entry.triggers.first
      work_directory = cron_entry.working_directory

      ts = Win32::TaskScheduler.new(nil, nil, cron_entry.task_folder, true)
      begin
        ts.password = pw
        ts.new_work_item(task_name, trigger)
        ts.application_name = 'cmd'
        ts.parameters = '/C ' + parameters
        ts.working_directory = work_directory
        ts.activate(task_name)
      rescue
        raise 'Failed at setting the task up. It might have been partially created/updated. This most likely means a bad password was entered.'
      end

      task_name
    end

    def generate_task_name task_name
      "#{task_name}.#{identifier}"
    end

    def identifier
      # Removing the characters blocked by the windows file system. The single quote is just for simplicity.
      iden = @options[:identifier].gsub(/[:\/\\<>:"|?*']/, '_')
      raise 'Identifier must contain at least one letter or number.' unless iden =~ /\w/
      iden
    end

    def validate_password password
      # Validate a password by trying to create a task with it. If it fails, then the password is wrong.
      # Will delete the created task after.
      ts = Win32::TaskScheduler.new
      base_test_task_name = test_task_name = "Winever_test_task"
      i = 0
      while ts.exists?(test_task_name)
        i += 1
        test_task_name = "#{base_test_task_name}_#{i}"
      end

      trigger = { :start_year   => 2000,
                  :start_month  => 6,
                  :start_day    => 12,
                  :start_hour   => 13,
                  :start_minute => 17,
                  :trigger_type => Win32::TaskScheduler::TASK_TIME_TRIGGER_ONCE}

      ts.new_work_item(test_task_name, trigger)
      valid = false
      begin
        ts.password = password
        ts.application_name = "cmd"
        valid = true
      rescue
        ts.password = nil
        valid = false
      end
      ts.delete(test_task_name)

      return valid
    end

  end

end