# $Id: 013_update_building.rb 338 2009-10-11 05:52:52Z toshiyuki.ando1971 $

require 'hudson_build'

class UpdateHudsonBuildsErrorAndCausedBy < ActiveRecord::Migration
  def self.up
    HudsonBuild.update_all "error = ''", "error IS NULL"
    HudsonBuild.update_all "caused_by = 1", "caused_by IS NULL"
  end

  def self.down
  end
end
