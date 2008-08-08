namespace :yui_on_rails do
  def run_rake(target = "")
    rake = fetch(:rake, "rake")
    rails_env = fetch(:rails_env, "production")
    run "cd #{current_release}; #{rake} RAILS_ENV=#{rails_env} #{target}"
  end

  task :update, :except => { :no_release => true } do
    run_rake "yui_on_rails:update"
  end
end
after "deploy:update_code", "yui_on_rails:update"

require 'capistrano/recipes/deploy/scm/git'
Capistrano::Deploy::SCM::Git.class_eval do
  alias_method :_original_checkout_, :checkout
  def checkout(revision, destination)
    execute = [_original_checkout_(revision, destination)]
    execute << "(cd vendor/plugins/yui_on_rails && #{command} submodule #{verbose} init && #{command} submodule #{verbose} update)"
    execute.join(" && ")
  end

  alias_method :_original_sync_, :sync
  def sync(revision, destination)
    execute = [_original_sync_(revision, destination)]
    execute << "(cd vendor/plugins/yui_on_rails && #{command} submodule #{verbose} init && #{command} submodule #{verbose} update)"
    execute.join(" && ")
  end
end
