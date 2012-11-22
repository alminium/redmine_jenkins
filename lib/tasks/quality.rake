desc 'Auto Code Review Redmine Hudson Plugin'
begin
  namespace :redmine_jenkins do
    task :reek => [:cd_plugin_dir, :environment] do
      desc 'check code smell(reek) for Hudson Plugin'
      require "reek"
      system "reek app lib test > reek.log"
    end

    task :roodi => [:cd_plugin_dir, :environment] do
      desc 'check code smell(reek) for Hudson Plugin'
      require "roodi"
      system "roodi app/**/*.rb lib/**/*.rb test/**/*.rb > roodi.log"
    end

    task :flog => [:cd_plugin_dir, :environment] do
      desc 'check complexity for Hudson Plugin'
      require "flog"
      system "flog app lib test > flog.log"
    end

    task :flay => [:cd_plugin_dir, :environment] do
      desc 'check dry for Hudson Plugin'
      require "flay"
      system "flay > flay.log"
    end

    task :cd_plugin_dir do
      Dir.chdir("vendor/plugins/redmine_jenkins")
    end

    task :quality => [:reek, :roodi, :flog, :flay]
  end
rescue LoadError => e
  # rcov not available
  $stderr.print "redmine_jenkins:testing load error #{e}"
end
