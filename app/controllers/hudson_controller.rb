# $Id$
# To change this template, choose Tools | Templates
# and open the template in the editor.

require "rexml/document"
require 'cgi'
require 'hudson_exceptions'
require 'date'

RAILS_DEFAULT_LOGGER.info 'Starting Hudson plugin for RedMine'

class HudsonController < ApplicationController
  unloadable
  layout 'base'

  before_filter :find_project
  before_filter :find_settings
  before_filter :find_hudson_jobs
  before_filter :authorize
  before_filter :clear_flash

  include HudsonHelper
  include RexmlHelper

  def index
    raise HudsonNoSettingsException if @settings.is_new?

    content = ""
    begin
      # job/build, view, primaryView は省く
      api_url = "#{@settings.url}api/xml?depth=1" +
                "&xpath=/hudson" +
                "&exclude=/hudson/view" +
                "&exclude=/hudson/primaryView" +
                "&exclude=/hudson/job/build" +
                "&exclude=/hudson/job/lastCompletedBuild" +
                "&exclude=/hudson/job/lastStableBuild" +
                "&exclude=/hudson/job/lastSuccessfulBuild"
      content = open_hudson(api_url, @settings.auth_user, @settings.auth_password)
    rescue HudsonHttpException => error
      flash.now[:error] = error.message
      return
    end

    doc = REXML::Document.new content

    # 全てのジョブの状態を更新する
    update_all_jobs doc

    # 最新のビルド情報をチェックする
    update_all_builds doc

  rescue HudsonNoSettingsException
    flash.now[:error] = l(:notice_err_no_settings, url_for(:controller => 'hudson_settings', :action => 'edit', :id => @project))
  end

  def build
    raise HudsonNoSettingsException if @settings.is_new?
    raise HudsonNoJobException if params[:name] == nil

    build_url = "#{@settings.url}job/#{params[:name]}/build"

    content = open_hudson(build_url, @settings.auth_user, @settings.auth_password)

  rescue HudsonHttpException => error
    render :text => error.message
  rescue HudsonNoSettingsException
    render :text => "#{l(:notice_err_build_failed, :notice_err_no_settings)}"
  rescue HudsonNoJobException
    render :text => "#{l(:notice_err_build_failed_no_job, params[:name])}"
  else
    render :text => "#{params[:name]} #{l(:build_accepted)}"
  end

  def history
    raise HudsonNoSettingsException if @settings.is_new?
    raise HudsonNoJobException if params[:name] == nil
    raise HudsonNoJobException unless is_target?(params[:name]) # ちょっと強引だけど、見えない設定のジョブはないものとみなす

    @name = params[:name]
    api_uri = "#{@settings.url}job/#{params[:name]}/rssAll"
    content = open_hudson(api_uri, @settings.auth_user, @settings.auth_password)
    doc = REXML::Document.new content
    @builds = []
    doc.elements.each("//entry") do |entry|
      buildinfo = parse_rss_build(entry)
      @builds << buildinfo
    end

  rescue HudsonHttpException => error
    render :text => error.message
  rescue HudsonNoSettingsException
    render :text => "#{l(:notice_err_no_settings, url_for(:controller => 'hudson_settings', :action => 'edit', :id => @project))}"
  rescue HudsonNoJobException
    render :text => "#{l(:notice_err_no_job, params[:name])}"
  else
    render :partial => 'history'
  end

private
  def find_project
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_settings
    @settings = HudsonSettings.load(@project)
  end

  def find_hudson_jobs
    @jobs = HudsonJob.find :all, :order => "#{HudsonJob.table_name}.name",
                           :conditions => ["#{HudsonJob.table_name}.project_id = ?", @project.id]
  end

  def clear_flash
    flash.clear
  end

  def is_target?(job)
    return @settings.job_include?(job)
  end

  def update_all_jobs(doc)
    doc.elements.each("hudson/job") do |element|
      job_name = get_element_value(element, "name")
      next unless is_target?(job_name)

      job = get_job(job_name)
      job = new_job(job_name) unless job

      job.update_by_xml(element)
      job.update_health_report_by_xml(element)
      job.save
    end
  end

  def update_all_builds(doc)

    # 更新が必要かどうかを確認する
    doc.elements.each("hudson/job") do |element|
      job_name = get_element_value(element, "name")
      next unless is_target?(job_name)

      job = get_job(job_name)
      next unless job

      latest_build = element.elements["lastBuild"]
      next unless latest_build

      latest_build_number = get_element_value(latest_build, "number")

      if job.latest_build_number == latest_build_number
        build = get_latest_build_from_db job, latest_build_number
        job.builds << build if build
      end

      # 最新のビルドが変わっているようならビルドの情報を更新する
      if job.latest_build_number != latest_build_number
        builds = get_recent_builds_from_hudson job, latest_build_number
        new_latest = ""
        builds.each {|build|
          job.builds << build
          new_latest = build.number if !build.building and new_latest == ""
        }
        if new_latest != ""
          job.latest_build_number = new_latest
        end
        job.save
      end
    end
  end

  def get_job(job_name)
      job = @jobs.find{|job| job.name == job_name }
      return job
  end

  def new_job(job_name)
      retval = HudsonJob.new
      retval.name = job_name
      retval.project_id = @project.id
      retval.hudson_id = @settings.id
      @jobs << retval
      return retval
  end

  def get_recent_builds_from_hudson( job, latest_build_number )
    begin
      # rssAll で取得できる範囲で。
      api_url = "#{@settings.url}job/#{job.name}/rssAll"
      content = open_hudson(api_url, @settings.auth_user, @settings.auth_password)
    rescue HudsonHttpException => error
      flash.now[:error] = error.message
      return
    end

    retval = []

    doc = REXML::Document.new content
    doc.elements.each("//entry") do |entry|
      buildinfo = parse_rss_build(entry)
      next if ( job.latest_build_number != nil and ( job.latest_build_number.to_i >= buildinfo[:number].to_i ) )
      build = new_build(job, buildinfo)
      #changesets = get_changesets_from_hudson(job, build)
      #changesets.each{|changeset| build.changesets << changeset}
      build.save
      retval << build
    end

    # 最新のビルドが実行中の場合、rssAll にはエントリがない
    if latest_build_number != nil and ( retval.length == 0 or retval[0].number.to_i < latest_build_number.to_i )
      build = new_build(job, {:number=>latest_build_number, :result=>'', :published=> Time.now, :building=>true})
      retval << build
    end

    return retval
  end

  def get_latest_build_from_db( job, latest_build_number )
    return if latest_build_number == nil || latest_build_number == ""
    retval = HudsonBuild.find( :first,
                               :conditions => ["#{HudsonBuild.table_name}.hudson_job_id = ? and #{HudsonBuild.table_name}.number = ?", job.id, latest_build_number] )
    return retval
  end

  def new_build(job, buildinfo)
    retval = HudsonBuild.new()
    retval.hudson_job_id = job.id
    retval.number = buildinfo[:number]
    retval.result = buildinfo[:result]
    retval.finished_at = buildinfo[:published]
    retval.building = buildinfo[:building]
    retval.caused_by = 1 # デフォルトのAdminを想定している
    retval.error = ""
    return retval
  end

  def new_changesets(job, build)
    api_url = "#{@settings.url}job/#{job.name}/#{build.number}/api/xml"
    content = open_hudson(api_url, @settings.auth_user, @settings.auth_password)

    doc = REXML::Document.new content
    doc.elements.each("//changeSet") do |element|
      changesetinfo = parse_changeset(element)
      changesetinfo[:revisions].each {|revision|
        changeset = new_changeset(build, revision)
        build.changesets << changeset
      }
    end
  rescue HudsonHttpException => error
    return
  rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT
    return
  rescue URI::InvalidURIError
    return
  end

  def new_changeset(build, revisioninfo)
    retval = HudsonBuildChangeset.new
    retval.hudson_build_id = build.id
    retval.repository_id = @project.repository.id
    retval.revision = revisioninfo[:revision]
    return retval
  end
end
