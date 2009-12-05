# $Id$

class AddGetBuildDetailsToHudsonSettings < ActiveRecord::Migration
  def self.up
    add_column :hudson_settings, :get_build_details, :boolean, :default => true
  end

  def self.down
    remove_column :hudson_settings, :get_build_details
  end
end
