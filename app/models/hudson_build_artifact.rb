# $Id$

class HudsonBuildArtifact < ActiveRecord::Base
  unloadable
  belongs_to :build, :class_name => 'HudsonBuild', :foreign_key => 'hudson_build_id'

  # 空白を許さないもの
  validates_presence_of :hudson_build_id, :display_path, :file_name, :relative_path

end
