# $Id$

class HudsonApplicationHooks < Redmine::Hook::ViewListener

  def view_layouts_base_html_head(context = {})
    project = context[:project]
    return '' unless project
    controller = context[:controller]
    return '' unless controller
    action_name = controller.action_name
    return '' unless action_name

    if (controller.class.name == 'ProjectsController' and action_name == 'activity')
      settings = HudsonSettings.load(project)
      return '' unless settings
      o = ""
      o << "<style type='text/css'>"
      o << ".hudson-build { background-image: url(#{settings.url}favicon.ico); }"
      o << "</style>\n"
      return o
    end
  end

  def view_issues_show_description_bottom(context = {})
    return '' unless context[:issue]
    issue = context[:issue]
    o = ''
    o << "<script type='text/javascript'>" + "\n"
    o << "document.observe('dom:loaded', function() {" + "\n"
    o << "});\n"
    o << "</script>"
  end
end
