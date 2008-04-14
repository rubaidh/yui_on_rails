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

  # FIXME: This is somewhat brittle, no?  I don't believe +assert_dom_equal+
  # is quite as useful as it could be in asserting that the DOM structure is
  # the same while not worrying about whitespace?
  def test_calendar_select_produces_the_appropriate_html_and_js
    expected = %(<input name="post[published_at(1i)]" type="hidden" id="post_published_at_1i" value="" />
<input name="post[published_at(2i)]" type="hidden" id="post_published_at_2i" value="" />
<input name="post[published_at(3i)]" type="hidden" id="post_published_at_3i" value="" />
<div id="post_published_at"></div><script type="text/javascript">
//<![CDATA[
          YAHOO.namespace('Rails.Calendar.Post.PublishedAt');
          YAHOO.Rails.Calendar.Post.PublishedAt.initializeCalendar = function() {
            var theCalendar = new YAHOO.widget.Calendar('post_published_at', {navigator:true, start_weekday:1, title:'Published at'});

            theCalendar.render();

            theCalendar.selectEvent.subscribe(function(type, args) {
              var dates = args[0];
              var date = dates[0];

              YAHOO.util.Dom.get("post_published_at_3i").value   = date[2];
              YAHOO.util.Dom.get("post_published_at_2i").value = date[1];
              YAHOO.util.Dom.get("post_published_at_1i").value  = date[0];
            });
          }

          YAHOO.util.Event.onDOMReady(YAHOO.Rails.Calendar.Post.PublishedAt.initializeCalendar);

//]]>
</script>)

    assert_dom_equal expected, calendar_select(:post, :published_at)
  end

  def test_calendar_select_produces_the_appropriate_html_and_js_with_different_field_names
    expected = %(<input name="cheese[matured_at(1i)]" type="hidden" id="cheese_matured_at_1i" value="" />
<input name="cheese[matured_at(2i)]" type="hidden" id="cheese_matured_at_2i" value="" />
<input name="cheese[matured_at(3i)]" type="hidden" id="cheese_matured_at_3i" value="" />
<div id="cheese_matured_at"></div><script type="text/javascript">
//<![CDATA[
          YAHOO.namespace('Rails.Calendar.Cheese.MaturedAt');
          YAHOO.Rails.Calendar.Cheese.MaturedAt.initializeCalendar = function() {
            var theCalendar = new YAHOO.widget.Calendar('cheese_matured_at', {navigator:true, start_weekday:1, title:'Matured at'});

            theCalendar.render();

            theCalendar.selectEvent.subscribe(function(type, args) {
              var dates = args[0];
              var date = dates[0];

              YAHOO.util.Dom.get("cheese_matured_at_3i").value   = date[2];
              YAHOO.util.Dom.get("cheese_matured_at_2i").value = date[1];
              YAHOO.util.Dom.get("cheese_matured_at_1i").value  = date[0];
            });
          }

          YAHOO.util.Event.onDOMReady(YAHOO.Rails.Calendar.Cheese.MaturedAt.initializeCalendar);

//]]>
</script>)

    assert_dom_equal expected, calendar_select(:cheese, :matured_at)
  end

  def test_we_can_change_the_start_weekday
    expected = %(<input name="post[published_at(1i)]" type="hidden" id="post_published_at_1i" value="" />
<input name="post[published_at(2i)]" type="hidden" id="post_published_at_2i" value="" />
<input name="post[published_at(3i)]" type="hidden" id="post_published_at_3i" value="" />
<div id="post_published_at"></div><script type="text/javascript">
//<![CDATA[
          YAHOO.namespace('Rails.Calendar.Post.PublishedAt');
          YAHOO.Rails.Calendar.Post.PublishedAt.initializeCalendar = function() {
            var theCalendar = new YAHOO.widget.Calendar('post_published_at', {navigator:true, start_weekday:0, title:'Published at'});

            theCalendar.render();

            theCalendar.selectEvent.subscribe(function(type, args) {
              var dates = args[0];
              var date = dates[0];

              YAHOO.util.Dom.get("post_published_at_3i").value   = date[2];
              YAHOO.util.Dom.get("post_published_at_2i").value = date[1];
              YAHOO.util.Dom.get("post_published_at_1i").value  = date[0];
            });
          }

          YAHOO.util.Event.onDOMReady(YAHOO.Rails.Calendar.Post.PublishedAt.initializeCalendar);

//]]>
</script>)

    assert_dom_equal expected, calendar_select(:post, :published_at, :start_weekday => 0)
  end

  def test_we_can_change_the_title
    expected = %(<input name="post[published_at(1i)]" type="hidden" id="post_published_at_1i" value="" />
<input name="post[published_at(2i)]" type="hidden" id="post_published_at_2i" value="" />
<input name="post[published_at(3i)]" type="hidden" id="post_published_at_3i" value="" />
<div id="post_published_at"></div><script type="text/javascript">
//<![CDATA[
          YAHOO.namespace('Rails.Calendar.Post.PublishedAt');
          YAHOO.Rails.Calendar.Post.PublishedAt.initializeCalendar = function() {
            var theCalendar = new YAHOO.widget.Calendar('post_published_at', {navigator:true, start_weekday:1, title:'Custom title'});

            theCalendar.render();

            theCalendar.selectEvent.subscribe(function(type, args) {
              var dates = args[0];
              var date = dates[0];

              YAHOO.util.Dom.get("post_published_at_3i").value   = date[2];
              YAHOO.util.Dom.get("post_published_at_2i").value = date[1];
              YAHOO.util.Dom.get("post_published_at_1i").value  = date[0];
            });
          }

          YAHOO.util.Event.onDOMReady(YAHOO.Rails.Calendar.Post.PublishedAt.initializeCalendar);

//]]>
</script>)

    assert_dom_equal expected, calendar_select(:post, :published_at, :title => "Custom title")
  end

  def test_we_can_set_the_minimum_date_as_a_string
    expected = %(<input name="post[published_at(1i)]" type="hidden" id="post_published_at_1i" value="" />
<input name="post[published_at(2i)]" type="hidden" id="post_published_at_2i" value="" />
<input name="post[published_at(3i)]" type="hidden" id="post_published_at_3i" value="" />
<div id="post_published_at"></div><script type="text/javascript">
//<![CDATA[
          YAHOO.namespace('Rails.Calendar.Post.PublishedAt');
          YAHOO.Rails.Calendar.Post.PublishedAt.initializeCalendar = function() {
            var theCalendar = new YAHOO.widget.Calendar('post_published_at', {mindate:'03/31/2007', navigator:true, start_weekday:1, title:'Published at'});

            theCalendar.render();

            theCalendar.selectEvent.subscribe(function(type, args) {
              var dates = args[0];
              var date = dates[0];

              YAHOO.util.Dom.get("post_published_at_3i").value   = date[2];
              YAHOO.util.Dom.get("post_published_at_2i").value = date[1];
              YAHOO.util.Dom.get("post_published_at_1i").value  = date[0];
            });
          }

          YAHOO.util.Event.onDOMReady(YAHOO.Rails.Calendar.Post.PublishedAt.initializeCalendar);

//]]>
</script>)

    assert_dom_equal expected, calendar_select(:post, :published_at, :mindate => "03/31/2007")
  end

  def test_we_can_set_the_minimum_date_as_a_ruby_date
    expected = %(<input name="post[published_at(1i)]" type="hidden" id="post_published_at_1i" value="" />
<input name="post[published_at(2i)]" type="hidden" id="post_published_at_2i" value="" />
<input name="post[published_at(3i)]" type="hidden" id="post_published_at_3i" value="" />
<div id="post_published_at"></div><script type="text/javascript">
//<![CDATA[
          YAHOO.namespace('Rails.Calendar.Post.PublishedAt');
          YAHOO.Rails.Calendar.Post.PublishedAt.initializeCalendar = function() {
            var theCalendar = new YAHOO.widget.Calendar('post_published_at', {mindate:'03/31/2007', navigator:true, start_weekday:1, title:'Published at'});

            theCalendar.render();

            theCalendar.selectEvent.subscribe(function(type, args) {
              var dates = args[0];
              var date = dates[0];

              YAHOO.util.Dom.get("post_published_at_3i").value   = date[2];
              YAHOO.util.Dom.get("post_published_at_2i").value = date[1];
              YAHOO.util.Dom.get("post_published_at_1i").value  = date[0];
            });
          }

          YAHOO.util.Event.onDOMReady(YAHOO.Rails.Calendar.Post.PublishedAt.initializeCalendar);

//]]>
</script>)

    assert_dom_equal expected, calendar_select(:post, :published_at, :mindate => Date.new(2007,03,31))
  end

  def test_we_can_set_the_maximum_date_as_a_string
    expected = %(<input name="post[published_at(1i)]" type="hidden" id="post_published_at_1i" value="" />
<input name="post[published_at(2i)]" type="hidden" id="post_published_at_2i" value="" />
<input name="post[published_at(3i)]" type="hidden" id="post_published_at_3i" value="" />
<div id="post_published_at"></div><script type="text/javascript">
//<![CDATA[
          YAHOO.namespace('Rails.Calendar.Post.PublishedAt');
          YAHOO.Rails.Calendar.Post.PublishedAt.initializeCalendar = function() {
            var theCalendar = new YAHOO.widget.Calendar('post_published_at', {maxdate:'03/31/2007', navigator:true, start_weekday:1, title:'Published at'});

            theCalendar.render();

            theCalendar.selectEvent.subscribe(function(type, args) {
              var dates = args[0];
              var date = dates[0];

              YAHOO.util.Dom.get("post_published_at_3i").value   = date[2];
              YAHOO.util.Dom.get("post_published_at_2i").value = date[1];
              YAHOO.util.Dom.get("post_published_at_1i").value  = date[0];
            });
          }

          YAHOO.util.Event.onDOMReady(YAHOO.Rails.Calendar.Post.PublishedAt.initializeCalendar);

//]]>
</script>)

    assert_dom_equal expected, calendar_select(:post, :published_at, :maxdate => "03/31/2007")
  end

  def test_we_can_set_the_maximum_date_as_a_ruby_date
    expected = %(<input name="post[published_at(1i)]" type="hidden" id="post_published_at_1i" value="" />
<input name="post[published_at(2i)]" type="hidden" id="post_published_at_2i" value="" />
<input name="post[published_at(3i)]" type="hidden" id="post_published_at_3i" value="" />
<div id="post_published_at"></div><script type="text/javascript">
//<![CDATA[
          YAHOO.namespace('Rails.Calendar.Post.PublishedAt');
          YAHOO.Rails.Calendar.Post.PublishedAt.initializeCalendar = function() {
            var theCalendar = new YAHOO.widget.Calendar('post_published_at', {maxdate:'03/31/2007', navigator:true, start_weekday:1, title:'Published at'});

            theCalendar.render();

            theCalendar.selectEvent.subscribe(function(type, args) {
              var dates = args[0];
              var date = dates[0];

              YAHOO.util.Dom.get("post_published_at_3i").value   = date[2];
              YAHOO.util.Dom.get("post_published_at_2i").value = date[1];
              YAHOO.util.Dom.get("post_published_at_1i").value  = date[0];
            });
          }

          YAHOO.util.Event.onDOMReady(YAHOO.Rails.Calendar.Post.PublishedAt.initializeCalendar);

//]]>
</script>)

    assert_dom_equal expected, calendar_select(:post, :published_at, :maxdate => Date.new(2007,03,31))
  end

end