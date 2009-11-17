# $Id$
desc 'Test Redmine Hudson Plugin'
begin
  rcov_options = "-I ../../../lib -x redmine"

  namespace :redmine_hudson do
    namespace :test do
      task :unit => [:environment, :init_fixtures] do
        desc 'unittest for Hudson Plugin'

        Dir.chdir("vendor/plugins/redmine_hudson")
        system "rcov #{rcov_options} test/unit/*_test.rb"
      end

      task :feature => [] do
        desc 'features for Hudson Plugin'

        Dir.chdir("vendor/plugins/redmine_hudson")
        system "cucumber test/features -S"
      end

      task :init_fixtures do
        desc "Init Fixtures"
        Rake::Task["test:plugins:setup_plugin_fixtures"].invoke
      end
    end
  end
rescue LoadError => e
  # rcov not available
  $stderr.print "redmine_hudson:testing load error #{e}"
end
