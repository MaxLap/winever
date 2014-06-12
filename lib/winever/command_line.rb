module Winever
  class CommandLine
    def self.execute options={}
      new(options).run
    end

    def initialize options={}
      @options = options

      @options[:file]       ||= 'config/schedule.rb'
      @options[:cut]        ||= 0
      @options[:identifier] ||= default_identifier

      unless File.exists?(@options[:file])
        warn("[fail] Can't find file: #{@options[:file]}")
        exit(1)
      end

      if [@options[:update], @options[:clear]].compact.length > 1
        warn("[fail] Can only update or clear. Choose one.")
        exit(1)
      end

      unless @options[:cut].to_s =~ /[0-9]*/
        warn("[fail] Can't cut negative lines from the crontab #{options[:cut]}")
        exit(1)
      end
      @options[:cut] = @options[:cut].to_i
    end


    def run
      if @options[:update]
        Winever::TaskManager.update_tasks(@options)
      elsif @options[:clear]
        Winever::TaskManager.clear_tasks(@options)
      else
        puts Winever::WheneverInterface.cron(@options)
        puts "## [message] Above is your schedule file converted to cron-winever syntax; your crontab  file /scheduled tasks were not updated."
        puts "## [message] Run `winever --help' for more options."
        exit(0)
      end
    end

    #protected

    def default_identifier
      File.expand_path(@options[:file])
    end

  end


end