ActionController::Routing::Routes.draw do |map|
  map.connect 'projects/:id/:controller/:action', :controller => 'hudson'
  map.connect 'projects/:id/:controller/:action', :controller => 'hudson_settings'
end