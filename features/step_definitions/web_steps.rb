# coding: utf-8

When /^I go to (.*)$/ do |page_name|
  visit path_to(page_name)
end

When /^I click "([^"]*)"(| within "([^"]*)")$/ do |element, temp, area|
  area = "html" unless area
  within(area) do
    click_on element
  end
end

When /^I fill in "([^"]*)" for "([^"]*)"$/ do |value, field|
  fill_in(field, :with => value)
end

When /^I check "([^"]*)"$/ do |field|
  check(field)
end

When /^I should see "([^"]*)"$/ do |content|
  page.has_content?(content).should be_true
end

Then /^the field named "(.*?)" should contain "(.*?)"$/ do |field, value|
  find_field(field).value.should == value
end

Then /^the field named "(.*?)" should be empty$/ do |field|
  find_field(field).value.should be_empty 
end

Then /^the field named "(.*?)" should (not be|be) checked$/ do |field, be_or_not|
  if be_or_not == "be"
    find_field(field).should be_checked
  else
    find_field(field).should_not be_checked
  end
end

Then /^show me the page$/ do 
  save_and_open_page
end
