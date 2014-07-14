require 'winever/version'
require 'whenever'

# A very tiny monkey patch of Whenever, adding some helper functions in the schedule.
module Whenever
  class JobList
    # We are running from winever? If you need tasks only on your Windows or your Linux servers, you can use #winever?
    def winever?
      Winever::WheneverInterface.run_from_winever?
    end

    # If transitionning to Winever and you already have scheduled tasks that you also want removed when installing
    # your Winever schedule, you can give their paths to this functions and Winever will take care of it!
    def remove_existing_tasks *names
      Winever::WheneverInterface.remove_existing_tasks *names
    end
  end
end


module Winever
  autoload :CommandLine, 'winever/command_line'
  autoload :CronEntry, 'winever/cron_entry'
  autoload :CronTime, 'winever/cron_time'
  autoload :TaskManager, 'winever/task_manager'
  autoload :WheneverInterface, 'winever/whenever_interface'
end
