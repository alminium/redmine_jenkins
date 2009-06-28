# $Id$

class AddCausedByToHudsonBuild < ActiveRecord::Migration
  def self.up
    add_column :hudson_builds, :caused_by, :integer
  end

  def self.down
    remove_column :hudson_builds, :caused_by
  end
end
