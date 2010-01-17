# $Id$
require 'cucumber/rake/task'
desc 'Test Redmine Hudson Plugin'
begin
  rcov_options = "-I ../../../lib -x redmine"

  namespace :redmine_hudson do
    namespace :test do
      task :unit => [:cd_plugin_dir, :environment, :init_fixtures] do
        desc 'unittest for Hudson Plugin'
        system "rcov #{rcov_options} test/unit/*_test.rb"
      end

      task :feature => [:cd_plugin_dir, :do_feature] do
        desc 'featuretest for Hudson Plugin'
      end

      Cucumber::Rake::Task.new(:do_feature) do |t|
        t.cucumber_opts = "test/features -S"
        t.rcov = true
        t.rcov_opts = ["--rails", "--sort=coverage", "--exclude 'osx/objc,gems/,spec/,redmine'"]
        t.rcov_opts << %[-o "features_rcov"]
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
