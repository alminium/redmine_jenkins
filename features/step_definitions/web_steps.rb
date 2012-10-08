# coding: utf-8

When /^I go to (.*)$/ do |page_name|
  visit path_to(page_name)
end

When /^I should see "([^"]*)"$/ do |content|
  page.has_content?(content).should be_true
end

When /^I click "([^"]*)"$/ do |element|
  click_on element
end

When /^I fill in "([^"]*)" for "([^"]*)"$/ do |value, field|
  fill_in(field, :with => value)
end

When /^I check "([^"]*)"$/ do |field|
  check(field)
end

