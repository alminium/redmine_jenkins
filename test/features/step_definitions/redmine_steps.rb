# $Id$

Given /^I log on as a Admin$/ do
  @current_user = User.find_by_login("admin")
  return if @current_user
  @current_user = User.new(:mail => 'admin@example.com', :firstname => 'Admin', :lastname => 'Redmine')
  @current_user.login = "admin"
  @current_user.admin = true
  @current_user.save!
  User.stubs(:current).returns(@current_user)
end

Given /^I log on as a User$/ do
  @current_user = User.find_by_mail('couger-test@example.com')
  return if @current_user
  @current_user = User.new(:mail => 'couger-test@example.com', :firstname => 'Couger', :lastname => 'Test')
  @current_user.login = "couger_test"
  @current_user.save!
  
  User.stubs(:current).returns(@current_user)
end

Given /select "(.*)" as language/ do |language|
  raise Exception.new("current user is nil") unless @current_user
  case language
  when "English"
    code = "en"
  end
  raise Exception.new("Can't convert language #{language}") unless code
  @current_user.language = code
  @current_user.save!
end

Given /^I join "(.*)" Project as a "(.*)"/ do |project_name, role_name|
  raise Exception.new("current user is nil") unless @current_user
  role = Role.find_by_name(role_name)
  raise Exception.new("no such role #{role_name}") unless role
  project = Project.find_by_name(project_name)
  raise Exception.new("no such project name #{project_name}") unless project

  member = Member.new(:user_id => @current_user.id, :project_id => project.id, :roles => [role])
  member.save!
end

Given /^Project "(.*)" uses "(.*)" Plugin$/ do |project_name, plugin_name|
  project = Project.find_by_name(project_name)
  raise Exception.new("no such project name #{project_name}") unless project
  enabled_module = EnabledModule.new(:name => plugin_name, :project_id => project.id)
  project.enabled_modules << enabled_module
  enabled_module.save!
end

Given /"(.*)" has a permission "(.*)"/ do |role_name, permission|
  role = Role.find_by_name(role_name)
  raise Exception.new("no such role #{role_name}") unless role
  permission.split(",").each do |item|
    role.add_permission!(item)
  end
  role.save!
end

Given /Issue #(.*) is related to revisions "(.*)"/ do |issue_no, revisions|
  issue = Issue.find(issue_no)
  raise Exception.new("issue not found - #{issue_no}") unless issue
  revisions.split(/,/).each do |revision|
    changeset = Changeset.find(:first, :conditions => ["repository_id = ? and revision = ?", issue.project.repository.id, revision])
    raise Exception.new("no such changeset - #{issue.project.name} rev-#{revision}") unless changeset
    Changeset.connection.execute("INSERT INTO changesets_issues (changeset_id, issue_id) values (#{changeset.id}, #{issue.id})")
  end
end
