module Winever
  class CommandLine

    def self.run_from_command_line_options
      require 'optparse'

      options = {}

      OptionParser.new do |opts|
        opts.banner = "Usage: whenever [options]"
        opts.on('-i', '--update [identifier]', 'Default: full path to schedule.rb file') do |identifier|
          options[:update] = true
          options[:identifier] = identifier if identifier
        end
        opts.on('-c', '--clear [identifier]') do |identifier|
          options[:clear] = true
          options[:identifier] = identifier if identifier
        end
        opts.on('-s', '--set [variables]', 'Example: --set \'environment=staging&path=/my/sweet/path\'') do |set|
          options[:set] = set if set
        end
        opts.on('-f', '--load-file [schedule file]', 'Default: config/schedule.rb') do |file|
          options[:file] = file if file
        end
        opts.on('-k', '--cut [lines]', 'Cut lines from the top of the cronfile') do |lines|
          options[:cut] = lines.to_i if lines
        end
        opts.on('-v', '--version') { puts "Winever v#{Winever::VERSION}"; exit(0) }
      end.parse!

      self.execute(options)
    end

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