require File.join(File.dirname(__FILE__), "../../app/models", 'hudson_build')

class UpdateHudsonBuildsErrorAndCausedBy < ActiveRecord::Migration
  def self.up
    HudsonBuild.update_all "error = ''", "error IS NULL"
    HudsonBuild.update_all "caused_by = 1", "caused_by IS NULL"
  end

  def self.down
  end
end
