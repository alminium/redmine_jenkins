desc 'Fetch buildresults from the Hudson'

namespace :redmine_jenkins do
  task :fetch => :environment do
    Hudson.fetch
  end
end
