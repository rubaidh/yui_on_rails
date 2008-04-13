# Just require the containing Rails application's test helper for now.  I'm
# sure we can remove that dependency at some point, but I would need to figure
# out how to load bits of Rails anyway.
require "#{File.dirname(__FILE__)}/../../../../test/test_helper"
