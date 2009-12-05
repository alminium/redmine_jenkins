# $Id$

class CreateHudsonBuildTestResults < ActiveRecord::Migration
  def self.up
    create_table :hudson_build_test_results do |t|
      t.column :hudson_build_id, :integer
      t.column :fail_count, :integer
      t.column :skip_count, :integer
      t.column :total_count, :integer
    end
  end

  def self.down
    drop_table :hudson_build_test_results
  end
end
