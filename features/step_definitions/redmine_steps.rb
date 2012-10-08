# coding: utf-8

Given /^Project "([^"]*?)" uses "([^"]*?)" Plugin$/ do |project_name, plugin_name|
  steps %Q{
    When "admin" log on as a User
     And I go to ProjectSettings at "#{project_name}" Project
     And I click "Modules"
     And I check "#{plugin_name}"
     And I click "Save"
  }
end

Given /"(.*)" has a permission below:/ do |role_name, table|
  steps %Q{
    When "admin" log on as a User
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

Given /^"([^"]*)" log on as a User$/ do |login_name|
  steps %Q{
    When I go to "login"
     And I fill in "#{login_name}" for "Login"
     And I fill in "#{login_name}" for "Password"
     And I click "Login »"
    Then I should see "My page"
  }
end

