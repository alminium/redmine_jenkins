class HudsonSettingsHealthReport < ActiveRecord::Base
  unloadable
  belongs_to :settings, :class_name => 'HudsonSettings', :foreign_key => 'hudson_settings_id'

  # 空白を許さないもの
  validates_presence_of :hudson_settings_id, :keyword, :url_format

  def HudsonSettingsHealthReport.is_blank?(hash)
    return true if hash[:keyword] == nil and hash[:url_format] == nil
    return true if hash[:keyword] == "" and hash[:url_format] = ""
    return false
  end

  def update_from_hash(value)
    self.keyword = value[:keyword]
    self.url_format = value[:url_format]
  end

  def contained_in?(message)
    return false unless message
    return message.index(self.keyword) != nil
  end

  def get_url(job)
    ret_val = self.url_format
    ret_val = ret_val.gsub('${hudson.url}', job.settings.url)
    ret_val = ret_val.gsub('${job.name}', job.name)
    return ret_val
  end

end
