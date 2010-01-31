# $Id$

class ChangeColumnHudsonBuildNumber < ActiveRecord::Migration
  def self.up
    change_column :hudson_builds, :number, :integer
  end

  def self.down
    change_column :hudson_builds, :number, :string
  end
end
