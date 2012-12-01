# coding: utf-8

Given /^Hudson API returns "(.*?)"$/ do |response_name|
  HudsonApi.should_receive(:open).twice.and_return(get_response("#{response_name}"))
end

def get_response(name)
  f = open "#{Rails.root}/plugins/redmine_hudson/test/responses/#{name}.xml"
  retval = f.read
  f.close
  return retval
end
