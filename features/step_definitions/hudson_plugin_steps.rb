# coding: utf-8

When /^I add health report settings below:$/ do |table|
  table.hashes.each_with_index do |hash, index|
    step 'I click "Add HealthReport Setting"'

    fields_keyword = page.all(:xpath, "//input[contains(substring-after(@name, 'new_health_report_settings'), '[keyword]')]")
    fields_url = page.all(:xpath, "//input[contains(substring-after(@name, 'new_health_report_settings'), '[url_format]')]")

    fields_keyword[index].set(hash["keyword"])
    fields_url[index].set(hash["url_format"])
  end
end

When /^I should see health report settings below:$/ do |table|
  fields_keyword = page.all(:xpath, "//input[contains(@name, '[keyword]')]")
  fields_url     = page.all(:xpath, "//input[contains(@name, '[url_format]')]")

  fields_keyword.size.should == table.hashes.size
  fields_url.size.should == table.hashes.size

  table.hashes.each_with_index do |hash, index|
    fields_keyword[index].value.should == hash["keyword"]
    fields_url[index].value.should == hash["url_format"]
  end
end

Then /^I should see job list for settings:$/ do |job_list|
  actual = page.all("#job-list tr").map do |row|
    row.all("th,td").map do |cell|
      cell.text
    end
  end

  job_list.diff!(actual)
end
