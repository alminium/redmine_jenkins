desc 'Fetch buildresults from the Hudson'

namespace :redmine_hudson do
  task :fetch => :environment do
    Hudson.fetch
  end
end
