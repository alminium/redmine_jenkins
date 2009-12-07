# $Id$
# draw upon redmine_reports/features

require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

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
