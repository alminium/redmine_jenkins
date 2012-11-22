RedmineApp::Application.routes.draw do
  match 'projects/:id/jenkins/:action', :controller => 'hudson'
  match 'projects/:id/jenkins_settings/:action', :controller => 'hudson_settings'
end
