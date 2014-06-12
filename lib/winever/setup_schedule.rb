
if winever?
  set :job_template, "|:job"

  # Overwrite to put tasks in a different subfolder of the task scheduler.
  # Right now, anything other than \\ will break clear_tasks, so don't change folder for now.
  set :task_folder, "\\"

  job_type :command, ":task_folder|:task_name||:task :output"
  job_type :rake,    ":task_folder|:task_name|:path|:bundle_command rake :task --silent :environment_variable=:environment :output"
  job_type :script,  ":task_folder|:task_name|:path|:bundle_command script/:task :environment_variable=:environment :output"
  job_type :runner,  ":task_folder|:task_name|:path|:runner_command -e :environment ':task' :output"
end