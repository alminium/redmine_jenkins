RedmineApp::Application.routes.draw do
  match 'projects/:id/hudson/:action', :controller => 'hudson'
  match 'projects/:id/hudson_settings/:action', :controller => 'hudson_settings'
end
