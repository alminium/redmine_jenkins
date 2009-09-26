# $Id$
desc 'Fetch buildresults from the Hudson'



namespace :redmine_hudson do
  task :fetch_buildresults => :environment do
    Hudson.fetch
  end
end
