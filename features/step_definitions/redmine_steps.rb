# coding: utf-8

Given /^Project "([^"]*?)" uses "([^"]*?)" Plugin$/ do |project_name, plugin_name|
  steps %Q{
    When I am logged in as "admin" with password "admin"
     And I go to ProjectSettings at "#{project_name}" Project
     And I click "Modules"
     And I check "#{plugin_name}"
     And I click "Save"
  }
end

Given /"(.*)" has a permission below:/ do |role_name, table|
  steps %Q{
    When I am logged in as "admin" with password "admin"
     And I go to Roles 
     And I click "#{role_name}"
  }
  table.hashes.each do |hash|
    steps %Q{
      When I check "#{hash['permissions']}"
    }
  end
  steps %Q{
    When I click "Save"
  }
end

Given /^I am logged in as "([^"]*)" with password "([^"]*)"$/ do |login_name, password|
  steps %Q{
    When I go to "login"
     And I fill in "#{login_name}" for "Login"
     And I fill in "#{password}" for "Password"
     And I click "Login »"
    Then I should see "My page"
  }
end

