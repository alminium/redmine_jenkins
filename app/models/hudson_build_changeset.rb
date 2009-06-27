# $Id$

class HudsonBuildChangeset < ActiveRecord::Base
  belongs_to :build, :class_name => 'HudsonBuild', :foreign_key => 'hudson_build_id'
  
end
