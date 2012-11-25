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

