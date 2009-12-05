# $Id$

class CreateHudsonBuildArtifacts < ActiveRecord::Migration
  def self.up
    create_table :hudson_build_artifacts do |t|
      t.column :hudson_build_id, :integer
      t.column :display_path, :text, :default => ""
      t.column :file_name, :text, :default => ""
      t.column :relative_path, :text, :default => ""
    end
  end

  def self.down
    drop_table :hudson_build_artifacts
  end
end
