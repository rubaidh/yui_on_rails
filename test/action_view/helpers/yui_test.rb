require "#{File.dirname(__FILE__)}/../../test_helper"

class YuiTest < Test::Unit::TestCase
  def test_version_is_what_we_intend_it_to_be
    assert_equal "2.5.1", ActionView::Helpers::YUI::VERSION.to_s
  end
end
