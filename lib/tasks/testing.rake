# $Id$
desc 'Test Redmine Hudson Plugin'
begin
  require "rcov/rcovtask"

  rcov_options = "-I ../../../lib -x redmine"

  namespace :redmine_hudson do
    task :testing => [:environment, :init_fixtures] do
      desc 'Rcov for Hudson Plugin'

      Dir.chdir("vendor/plugins/redmine_hudson")
      system "rcov #{rcov_options} test/*/*_test.rb"
    end

    task :init_fixtures do
      desc "Init Fixtures"
      Rake::Task["test:plugins:setup_plugin_fixtures"].invoke
    end
  end
rescue LoadError => e
  # rcov not available
  $stderr.print "redmine_hudson:testing load error #{e}"
end
