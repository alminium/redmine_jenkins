# $Id$
class AddShowCompact < ActiveRecord::Migration
  def self.up
    add_column :hudson_settings, :show_compact, :boolean, :default => false
  end

  def self.down
    remove_column :hudson_settings, :show_compact
  end
end
