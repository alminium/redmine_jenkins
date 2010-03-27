# $Id$

class AddUrlForPluginToHudsonSettings < ActiveRecord::Migration
  def self.up
    add_column :hudson_settings, :url_for_plugin, :string, :default => ""
  end

  def self.down
    remove_column :hudson_settings, :url_for_plugin
  end
end
