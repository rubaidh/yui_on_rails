require "#{File.dirname(__FILE__)}/../test_helper"

class CalendarHelperTest < Test::Unit::TestCase
  include ActionView::Helpers::YUI::CalendarHelper

  silence_warnings do
    Post = Struct.new("Post", :id, :published_at, :updated_at)
    Post.class_eval do
      def id
        123
      end
      def id_before_type_cast
        123
      end
      def to_param
        '123'
      end
    end
  end

  def test_calendar_select_should_be_found
    expected = "Hello World."

    assert_dom_equal expected, calendar_select(:post, :published_at)
  end
end