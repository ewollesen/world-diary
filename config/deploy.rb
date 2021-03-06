require "bundler/vlad"
require "vlad/assets"


set :application, "wd"
set :domain, "wd.xmtp.net"
set :repository, "git@pain.xmtp.net:wd.git"
set :rbenv_version, "2.1.2"
set :bundle_cmd, "PATH=$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH RBENV_VERSION=#{rbenv_version} bundle"
set :rake_cmd, "#{bundle_cmd} exec rake"
set :sudo_flags, sudo_flags << "-S"

task :staging do
  set :rails_env, "development"
  set :deploy_to, "/opt/#{application}-dev"
  set :revision, "origin/staging"
  set :domain, "wd-dev.xmtp.net"
end

task :production do
  set :rails_env, "production"
  set :deploy_to, "/opt/#{application}"
  set :revision, "origin/master"
end
