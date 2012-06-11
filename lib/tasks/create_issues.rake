namespace :redmine_hudson do
  task :create_issues => :environment do
    tracker = Tracker.find_by_name("Feature")
    project = Project.find_by_identifier("rlabs-hudson")
    user = User.find_by_id(1)
    1500.times do |number|
      i = Issue.new
      i.tracker = tracker
      i.project = project
      i.subject = "test-#{number}"
      i.author = user
      i.save!
      puts "--- created #{number} ---"
    end
  end
end
