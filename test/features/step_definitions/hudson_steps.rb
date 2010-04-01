# $Id$
# draw upon redmine_reports/features

require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

Given /^"(.*)" Project Has Hudson Jobs:/ do |project_name, hudson_jobs_table|
  project = Project.find_by_name(project_name)
  raise Exception.new("project not found - #{project_name}") unless project

  jobs = []
  hudson_jobs_table.hashes.each do |hash|
    jobs << hash['name']
  end

  settings = HudsonSettings.find_by_project_id(project.id)
  settings = HudsonSettings.new unless settings
  settings.project_id = project.id
  settings.url = "http://redmine.local/hudson/"
  settings.job_filter = jobs.join(",")
  settings.look_and_feel = "Hudson"
  settings.save!

  hudson_jobs_table.hashes.each do |hash|
    job = HudsonJob.new
    job.project_id = project.id
    job.hudson_id = settings.id
    job.settings = settings
    job.name = hash['name']
    job.save!
  end

end

Given /^Hudson Job "(.*)" Has Hudson Build Results:/ do |job_name, build_results_table|
  job = HudsonJob.find_by_name(job_name)
  raise Exception.new("Hudson job not found - #{job_name}") unless job
  project = Project.find(job.project_id)
  raise Exception.new("project not found - #{job.project_id}") unless project
  build_results_table.hashes.each do |hash|
    build = HudsonBuild.new
    build.hudson_job_id = job.id
    build.number = hash['number']
    build.result = hash['result']
    build.finished_at = DateTime.now
    build.building = hash['building']
    build.error = hash['error']
    build.caused_by = hash['caused_by']
    build.job = job
    build.save!

    hash['revisions'].split(/,/).each do |revision|
      changeset = HudsonBuildChangeset.new
      changeset.hudson_build_id = build.id
      changeset.repository_id = project.repository.id
      changeset.revision = revision
      changeset.build = build
      changeset.save!
    end
  end
end

Given /^Hudson API returns "(.*)" as depth0/ do |hudson_job_name|
  @response_jobs = Net::HTTPSuccess.new(Net::HTTP.version_1_2, '200', 'OK')
  @response_jobs.stubs(:content_type).returns("text/html")
  @response_jobs.stubs(:body).returns(get_response(:hudson_1_fetch_job))
  
  Net::HTTP.any_instance.stubs(:request).returns(@response_jobs)
end

Given /^Hudson API returns "(.*)" as depth1/ do |hudson_job_name|
  @response_jobs = Net::HTTPSuccess.new(Net::HTTP.version_1_2, '200', 'OK')
  @response_jobs.stubs(:content_type).returns("text/html")
  @response_jobs.stubs(:body).returns(get_response(:hudson_1_fetch_job))

  @response_job_build_detail = Net::HTTPSuccess.new(Net::HTTP.version_1_2, '200', 'OK')
  @response_job_build_detail.stubs(:content_type).returns("text/html")
  @response_job_build_detail.stubs(:body).returns(get_response(:hudson_1_fetch_job_simple_ruby_application_build_detail_completed))

  Net::HTTP.any_instance.stubs(:request).returns(@response_jobs, @response_job_build_detail)
end
