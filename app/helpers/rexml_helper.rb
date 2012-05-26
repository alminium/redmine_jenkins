# -*- coding: utf-8 -*-

module RexmlHelper
    
  def get_element_value(element, name)
    return "" if element == nil
    return "" if element.get_text(name) == nil
    return "" if element.get_text(name).value == nil
    return element.get_text(name).value
  end

end
