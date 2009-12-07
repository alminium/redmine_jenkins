# $Id$

require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

Then /^the field named "([^\"]*)" should contain "([^\"]*)"$/ do |field, value|
  field_named(field).value.should =~ /#{value}/
end

Then /^I should see "(.*)" linked to "(.*)"$/ do |title, url|
  Nokogiri::HTML(response.body).search("a[href=\"#{url}\"]").select{|a| a.text.include?(title) }.should_not be_empty
end

