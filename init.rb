# $Id$
require 'redmine'

Redmine::Plugin.register :redmine_hudson do
  name 'Redmine Hudson plugin'
  author 'Toshiyuki Ando'
  description 'This is a Hudson plugin for Redmine'
  version '0.1.0'

  project_module :hudson do
    # パーミッション設定。
    permission :show_hudson_jobs, {:hudson => [:index]}
    permission :build_hudson_jobs, {:hudson => [:build]}, :require => :member
  end

  menu :project_menu, :hudson, { :controller => :hudson, :action => :index }, :param => :id, :caption => :label_hudson

end
