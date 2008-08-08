require "#{File.dirname(__FILE__)}/../../../test_helper"

class ButtonHelperTest < Test::Unit::TestCase
  include ActionView::Helpers::YUI::ButtonHelper

  def test_correctly_included
    assert self.class.included_modules.include?(ActionView::Helpers::YUI::ButtonHelper)
  end
end
