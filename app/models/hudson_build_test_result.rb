# To change this template, choose Tools | Templates
# and open the template in the editor.

class HudsonBuildTestResult < ActiveRecord::Base
  unloadable
  belongs_to :build, :class_name => 'HudsonBuild', :foreign_key => 'hudson_build_id'

  # 空白を許さないもの
  validates_presence_of :hudson_build_id

  # 重複を許さないもの
  validates_uniqueness_of :hudson_build_id

  def description_for_activity
    return "TestResults: #{fail_count}Failed #{skip_count}Skipped Total-#{total_count}"
  end

end
