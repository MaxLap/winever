require 'winever/version'
require 'whenever'

# A very tiny monkey patch of whatever, adding a function useable in the schedule to know if this is going through winever.
module Whenever
  class JobList
    # We are running from winever
    def winever?
      Winever::WheneverInterface.run_from_winever?
    end
  end
end


module Winever
  autoload :CommandLine, 'winever/command_line'
  autoload :CronEntry, 'winever/cron_entry'
  autoload :TaskManager, 'winever/task_manager'
  autoload :WheneverInterface, 'winever/whenever_interface'
end
