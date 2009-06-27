# $Id$

class HudsonApplicationHooks < Redmine::Hook::ViewListener
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
