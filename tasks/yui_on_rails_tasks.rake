namespace :yui_on_rails do
  desc "Update all YUI resources in the application."
  task :update => ["yui_on_rails:update:javascripts"]

  namespace :update do

    desc "Update the YUI javascripts in the application."
    task :javascripts do
      plugin_yui_dir = "#{RAILS_ROOT}/vendor/plugins/yui_on_rails/resources/yui"
      public_yui_dir = "#{RAILS_ROOT}/public/yui"

      FileUtils.ln_sf(plugin_yui_dir, public_yui_dir)
    end
  end
end