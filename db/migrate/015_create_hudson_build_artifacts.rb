# $Id$

class CreateHudsonBuildArtifacts < ActiveRecord::Migration
  def self.up
    create_table :hudson_build_artifacts do |t|
      t.column :hudson_build_id, :integer
      t.column :display_path, :text
      t.column :file_name, :text
      t.column :relative_path, :text
    end
  end

  def self.down
    drop_table :hudson_build_artifacts
  end
end
