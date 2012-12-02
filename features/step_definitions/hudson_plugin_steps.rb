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

When /^I fill in job settings:$/ do |table|
  table.hashes.each_with_index do |hash, index|
    job_index = index + 1 
    job_name = hash["Name"]

    set_checked "settings_jobs_#{job_name}", hash["Enable"]
    set_checked "job_settings_#{job_index}_build_rotate", hash["Delete Old Build"]
    fill_in "job_settings_#{job_index}_build_rotator_days_to_keep", :with => hash["Days To Keep"]
    fill_in "job_settings_#{job_index}_build_rotator_num_to_keep", :with => hash["Num To Keep"]
  end
end

Then /^I should see job settings:$/ do |job_list|
  actual = page.all("#job-list tr").map do |row|
    row.all("th,td").map do |cell|
      cell.text
    end
  end

  # Header
  actual[0][0] = "Enable"
  actual[0][-1] = "Delete"

  # Body(input)
  index = 1
  actual[1..-1].map! do |row|
    job_name = row[1]
    if page.has_field?("settings_jobs_#{job_name}")
      row[0] = page.find("#settings_jobs_#{job_name}").checked? == nil ? "false" : "true"
    end
    if page.has_field?("job_settings_#{index}_build_rotate")
      row[3] = page.find("#job_settings_#{index}_build_rotate").checked? == nil ? "false" : "true"
      row[4] = page.find("#job_settings_#{index}_build_rotator_days_to_keep").value
      row[5] = page.find("#job_settings_#{index}_build_rotator_num_to_keep").value
      index = index + 1
    end
    row
  end 

  job_list.diff!(actual)
end

def set_checked(locator, state)
  if state == "true"
    check locator
  else
    uncheck locator
  end
end
