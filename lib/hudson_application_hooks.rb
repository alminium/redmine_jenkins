# $Id$

class HudsonApplicationHooks < Redmine::Hook::ViewListener

  include ActionView::Helpers::DateHelper
  include ApplicationHelper

  def view_layouts_base_html_head(context = {})
    project = context[:project]
    return '' unless project
    controller = context[:controller]
    return '' unless controller
    action_name = controller.action_name
    return '' unless action_name

    baseurl = url_for(:controller => 'hudson', :action => 'index', :id => project) + '/../../..'

    if (controller.class.name == 'ProjectsController' and action_name == 'activity')
      hudson = Hudson.find_by_project_id(project.id)
      return '' unless hudson.settings.url
      o = ""
      o << "<style type='text/css'>"
      o << ".hudson-build { background-image: url(#{hudson.settings.url}favicon.ico); }"
      o << "</style>\n"
      o << "<!--[if IE]>"
      o << "<style type='text/css'>"
      o << ".hudson-build { background-image: url(#{baseurl}/plugin_assets/redmine_hudson/images/hudson_icon.png); }"
      o << "</style>\n"
      o << "<![endif]-->"
      return o
    end

    if (controller.class.name == 'IssuesController' and action_name == 'show')
      o = ""
      o << stylesheet_link_tag(baseurl + "/plugin_assets/redmine_hudson/stylesheets/hudson.css") + "\n"
      o << javascript_include_tag(baseurl + "/plugin_assets/redmine_hudson/javascripts/build_result.js") + "\n"
      o << javascript_include_tag(baseurl + "/plugin_assets/redmine_hudson/javascripts/revision_build_results.js") + "\n"
      return o
    end

  end

  def view_issues_show_description_bottom(context = {})
    return '' unless context[:issue]
    issue = context[:issue]

    begin
      build_results = render_hudson_build_results issue
    rescue => e
      return  "render_hudson_build_results error: #{e}"
    end

    o = ''
    o << "<script type='text/javascript'>" + "\n"
    o << "builds = $H();" + "\n"
    o << "Event.observe(window, 'load', add_build_info_to_changesets);" + "\n"
    o << "function add_build_info_to_changesets(){" + "\n"
    o << "  var messages = $$('div[class^=\"changeset\"] p');" + "\n"
    o << "  messages.each(function(message){" + "\n"
    o << "    if ( message.innerHTML.indexOf('#{l(:label_revision)}') > 0) {" + "\n"
    o << "  	  add_build_info_to_changeset(message);" + "\n"
    o << "    }" + "\n"
    o << "  });" + "\n"
    o << "};" + "\n"

    o << build_results
    
    o << "function add_build_info_to_changeset(message){" + "\n"
    o << "  var keys = builds.keys();" + "\n"
    o << "  for( var index=0; index<keys.length; index++ ) {" + "\n"
    o << "    build = builds.get(keys[index]);" + "\n"
  	o << "    if ( message.innerHTML.indexOf('#{l(:label_revision)} ' + keys[index]) > 0 ) {" + "\n"
    o << "      buildKeys = build.results.keys();" + "\n"
	  o << "      for ( var bIndex=0; bIndex<buildKeys.length; bIndex++ ) {" + "\n"
	  o << "        result = build.results.get(buildKeys[bIndex]);" + "\n"
	  o << "        message.innerHTML += '<br>' + result.message();" + "\n"
	  o << "      }" + "\n"
    o << "    }" + "\n"
    o << "  }" + "\n"
    o << "}" + "\n"
    o << "</script>"
  end

  def render_hudson_build_results(issue)
    o = ''
    issue.changesets.each do |changeset|
      builds = HudsonBuild.find_by_changeset(changeset)
      next if builds.length == 0
      o << "results = new RevisionBuildResults('#{changeset.revision}');" + "\n"
      builds.each do |build|
        job = HudsonJob.find(:first, :conditions=>["#{HudsonJob.table_name}.id = ?", build.hudson_job_id])
        finished_at_tag = link_to(distance_of_time_in_words(Time.now, build.finished_at),
                                  {:controller => 'activities', :action => 'index', :id => job.project.id, :from => build.finished_at.to_date},
                                  :title => format_time(build.finished_at))
        o << "results.add("
        o << "new BuildResult('#{job.name}',#{build.number},'#{build.result}','#{build.finished_at}','#{finished_at_tag}','#{build.url_for(:user)}'));" + "\n"
      end 
      o << "builds.set(results.revision, results);" + "\n"
    end
    o
  end
end
