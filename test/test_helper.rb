# $Id$
# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

# Ensure that we are using the temporary fixture path
Engines::Testing.set_fixture_path

def get_response(name)
  f = open(File.dirname(__FILE__) + "/responses/#{name}.xml")
  retval = f.read
  f.close
  return retval
end
