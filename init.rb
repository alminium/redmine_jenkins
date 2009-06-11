# $Id$
require 'redmine'

Redmine::Plugin.register :redmine_hudson do
  name 'Redmine Hudson plugin'
  author 'Toshiyuki Ando r-labs'
  url "http://www.r-labs.org/repositories/show/hudson" if respond_to?(:url)
  description 'This is a Hudson plugin for Redmine'
  version '0.1.2'
  requires_redmine :version_or_higher => '0.8.0'

  project_module :hudson do
    # パーミッション設定。
    permission :show_jobs, {:hudson => [:index, :history]}
    permission :build_jobs, {:hudson => [:build]}, :require => :member
    permission :edit_settings, {:hudson_settings => [:edit, :joblist]}
  end

  menu :project_menu, :hudson, { :controller => :hudson, :action => :index }, :param => :id, :caption => :label_hudson

end
