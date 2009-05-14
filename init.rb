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

  # とりあえずの設定。 "プロジェクト名" => {:url => "HudsonのURL", :job_filter => "表示したいジョブ"}
  settings :default => {'test-1' => {:url => 'http://192.168.0.51:8080/'},
                         'nextproject' => {:url => 'http://192.168.0.51:8080/', :job_filter => 'Empty;NUnit'}
                        }

  menu :project_menu, :hudson, { :controller => :hudson, :action => :index }, :param => :id, :caption => :label_hudson

end
