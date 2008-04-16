require "#{File.dirname(__FILE__)}/../../../test_helper"

class EditorHelperTest < Test::Unit::TestCase
  include ActionView::Helpers::YUI::EditorHelper

  def test_correctly_included
    assert self.class.included_modules.include?(ActionView::Helpers::YUI::EditorHelper)
  end
end
