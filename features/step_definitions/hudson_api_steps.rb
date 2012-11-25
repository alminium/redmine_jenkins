# coding: utf-8

Given /^Hudson API returns "(.*?)"$/ do |response_name|
  @response_jobs = Net::HTTPSuccess.new(Net::HTTP.version_1_2, '200', 'OK')
  @response_jobs.stubs(:content_type).returns("text/html")
  @response_jobs.stubs(:body).returns(get_response("#{response_name}"))
  
  Net::HTTP.any_instance.stubs(:request).returns(@response_jobs)
end

def get_response(name)
  f = open "#{Rails.root}/plugins/redmine_hudson/test/responses/#{name}.xml"
  retval = f.read
  f.close
  return retval
end
