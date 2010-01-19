# $Id$
desc 'Test Redmine Hudson Plugin'
begin
  rcov_unit_options = "-I ../../../lib -x redmine"
  rcov_cucumber_options = "--rails --sort=coverage --exclude 'osx/objc,gems/,spec/,redmine' -o features_rcov"

  namespace :redmine_hudson do
    namespace :test do
      task :unit => [:cd_plugin_dir, :environment, :init_fixtures] do
        desc 'unittest for Hudson Plugin'
        system "rcov #{rcov_unit_options} test/unit/*_test.rb"
      end

      task :feature => [:cd_plugin_dir] do
        desc 'featuretest for Hudson Plugin'
        require 'cucumber/rake/task'
        system "rcov #{rcov_cucumber_options} #{Cucumber::BINARY} -- test/features -S"
      end

      task :init_fixtures do
        desc "Init Fixtures"
        Rake::Task["test:plugins:setup_plugin_fixtures"].invoke
      end

      task :cd_plugin_dir do
        Dir.chdir("vendor/plugins/redmine_hudson")
      end
    end
  end
rescue LoadError => e
  # rcov not available
  $stderr.print "redmine_hudson:testing load error #{e}"
end
