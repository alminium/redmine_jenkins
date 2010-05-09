# $Id$

require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

When /^I show (.+)$/ do |page_name|
  visit path_to(page_name)
end

When /^I add health report settings - Keyword "(.*)" and URLFormat "(.*)"$/ do | keyword, url_format |
  doc = webrat.dom

  hudson_settings = HudsonSettings.find(:first) # テスト中は現在のもの以外に設定がないと判断
  
  form = doc.search("//form[@id=\"new_hudson_settings\"]")[0] unless hudson_settings
  form = doc.search("//form[@id=\"edit_hudson_settings_#{hudson_settings.id}\"]")[0] if hudson_settings

  settings_keyword = Nokogiri::XML::Node::new('input', doc)
  settings_url_format = Nokogiri::XML::Node::new('input', doc)

  settings_keyword["type"] = "text"
  settings_keyword["name"] = "new_health_report_settings[1][keyword]"
  settings_keyword["value"] = keyword
  settings_url_format["type"] = "text"
  settings_url_format["name"] = "new_health_report_settings[1][url_format]"
  settings_url_format["value"] = url_format

  form.add_child settings_keyword
  form.add_child settings_url_format
end

Then /^the field named "([^\"]*)" should contain "([^\"]*)"$/ do |field, value|
  field_named(field).value.should =~ /#{value}/
end

Then /^I should see "(.*)" linked to "(.*)"$/ do |title, url|
  Nokogiri::HTML(response.body).search("a[href=\"#{url}\"]").select{|a| a.text.include?(title) }.should_not be_empty
end

Then /^health_report_settings "([^\"]*)" should have Keyword "([^\"]*)" and URLFormat "([^\"]*)"$/ do |index, keyword, url_format|
  index_i = index.to_i
  hudson_settings = HudsonSettings.find(:first)
  raise Exception.new("HudsonSettings not found") unless hudson_settings
  raise Exception.new("too larget index(#{hudson_settings.health_report_settings.length}) - #{index}") if hudson_settings.health_report_settings.length < index_i
  hrs = hudson_settings.health_report_settings[index_i - 1]
  raise Exception.new("HudsonHealthReportSettings not found") unless hrs
  field_named("health_report_settings[#{hrs.id}][keyword]").value.should =~ /#{keyword}/
  field_named("health_report_settings[#{hrs.id}][url_format]").value.should =~ /#{url_format}/
end
