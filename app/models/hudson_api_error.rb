# To change this template, choose Tools | Templates
# and open the template in the editor.

class HudsonApiError

  attr_reader :class_name, :method_name, :exception

  def initialize(class_name, method_name, exception)
    @class_name = class_name
    @method_name = method_name
    @exception = exception
  end
end
