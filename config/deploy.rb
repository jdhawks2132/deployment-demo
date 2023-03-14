# config valid for current version and patch releases of Capistrano
lock '~> 3.17.1'

set :application, 'deployment-demo'
set :repo_url, 'git@github.com:jdhawks2132/deployment-demo.git'
set :branch, 'main'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/#{fetch(:application)}"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", 'config/master.key'

set :linked_files, %w[config/database.yml]
append :linked_files, 'config/credentials/production.key'

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "tmp/webpacker", "public/system", "vendor", "storage"
set :linked_dirs, %w[log tmp/pids tmp/sockets public/uploads public/assets]

set :puma_bind,
    "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log, "#{release_path}/log/puma.error.log"
set :puma_role, :web

# Restart Puma
namespace :puma do
  desc 'Restart application'
  task :restart do
    invoke 'puma:stop'
    invoke 'puma:start'
  end

  desc 'Stop application'
  task :stop do
    on roles(fetch(:puma_role)) do
      execute "if [ -e #{fetch(:puma_pid)} ] && kill -0 `cat #{fetch(:puma_pid)}`> /dev/null 2>&1; then kill -QUIT `cat #{fetch(:puma_pid)}`; fi"
    end
  end

  desc 'Start application'
  task :start do
    on roles(fetch(:puma_role)) do
      within current_path do
        execute :bundle, :exec, :puma, "-C #{release_path}/config/puma.rb", "> #{fetch(:puma_access_log)} 2>&1 &"
      end
    end
  end
end

after 'deploy:publishing', 'puma:restart'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
