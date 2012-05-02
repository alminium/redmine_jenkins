ActionController::Routing::Routes.draw do |map|
  map.connect 'projects/:id/hudson/:action', :controller => 'hudson'
  map.connect 'projects/:id/hudson_settings/:action', :controller => 'hudson_settings'
end
