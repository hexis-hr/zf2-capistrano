set :application, "zf2-capistrano"
set :deploy_to, "/var/www/#{application}"
default_run_options[:pty] = true

set :scm, :git
set :repository,  "git@github.com:memphys/zf2-capistrano.git"
set :deploy_via, :remote_cache
set :branch, "master"
set :keep_releases, 3

server "107.22.224.149", :app, :web, :db, :primary => true
set :ssh_options, {:forward_agent => true, :port => 22}
set :user, "deployer"
set :use_sudo, false

namespace :myproject do

    task :symlink, :roles => :app do
        run "mkdir -p #{shared_path}/vendor/ZendFramework/library"
        run "chmod -R 755 #{shared_path}/vendor/ZendFramework/library"
        run "ln -nfs /usr/local/ZendFramework-2.0.0beta3/library/Zend #{shared_path}/vendor/ZendFramework/library/Zend"
        run "rm -rf #{release_path}/vendor"
        run "ln -nfs #{shared_path}/vendor #{release_path}/vendor"
    end

    task :uploads, :roles => :app do
        run "mkdir -p #{shared_path}/public/uploads"
        run "chmod -R 775 #{shared_path}/public/uploads"
        run "ln -nfs #{shared_path}/public/uploads #{release_path}/public/uploads"
    end

    task :disable do
        run "mkdir -p #{shared_path}/public"
        run "echo 'Site is on maintenance right now. Sorry.' > #{shared_path}/public/maintenance.html"
        run "cp #{shared_path}/public/maintenance.html #{latest_release}/public/maintenance.html"
    end

    task :enable do
        run "rm -f #{latest_release}/public/maintenance.html"
    end

end

after "deploy:update_code", "myproject:disable"
after "deploy:symlink", "myproject:enable"
after "deploy:symlink", "myproject:symlink", "myproject:uploads"