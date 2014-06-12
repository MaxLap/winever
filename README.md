# Winever

Winever is a gem that adds features to the Whenever gem, making it also compatible with Windows, without breaking
anything when using the regular Whenever gem.

Winever creates and removes tasks in the Windows task scheduler.

## Installation

Add this line to your application's Gemfile:

    gem 'winever'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install

## Usage

Winever adds the command `winever` which behaves similarly to `whenever`.

You can use `winever` without parameters to list a "cron" file using an internal syntax. It will tell you which of the
jobs of your schedule are supported and which ones aren't. Just like with Whenever, you can use `winever -i` to install/update
the jobs on your Windows machine and `winever -c` to remove them.

Winever creates tasks in Windows' task scheduler. Those task

In order for a job to be compatible with Winever, it needs to have an additional option: task_name. Note that thise task_name
will have an identifier (similar to Whenever's comment in the crontab) added as suffix to enable Winever to remove old tasks when needed.
```
every 1.day, at: '00:30 am' do
  rake 'my_backup_task', :task_name => 'MyAppBackup'
end
```

If you define new job_types in your schedule. Then you will need to define it differently for Winever. To do so, first add
`require 'winever` to the top of your schedule file. This will add the function `winever?` to your schedule, which you can
use to define some tasks only for Windows or for Linux, and to define a job_type differently for Whenever and for Winever.
This is the basic line for create a job_type for Winever.

```
if winever?
  job_type :something, ":task_folder|:task_name|:path|command_you_want_executed_here :output"`
else
  job_type :something, "cd :path && command_you_want_executed_here :output"`
end
```

The pipes (|) are important, so make sure not to remove any.
If your task doesn't need to be run in the folder of your application (like the existing job_type "command" of whenever),
then remove the :path (leaving the pipes around it intact).

As of right now the only type of schedule that is supported are the daily ones (run once per day, at a specific time, every day).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
