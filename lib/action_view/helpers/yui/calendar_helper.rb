module ActionView
  module Helpers
    module YUI
      module CalendarHelper
        def calendar_select(object_name, method, options = {}, html_options = {})
          InstanceTag.new(object_name, method, self, nil, options.delete(:object)).to_calendar_select_tag(options, html_options)
        end
      end
    end

    class InstanceTag
      include Helpers::JavaScriptHelper
      include Helpers::FormHelper

      def to_calendar_select_tag(options = {}, html_options = {})
        defaults = {
          :navigator => true,
          :start_weekday => 1,
          :title => method_name.humanize
        }
        options = defaults.merge(options)

        datetime = value(object)
        options[:selected] = array_or_string_for_javascript(datetime.strftime("%m/%d/%Y")) unless datetime.blank?
        options[:pagedate] = array_or_string_for_javascript(datetime.strftime("%m/%Y"))    unless datetime.blank?
        options[:title] = array_or_string_for_javascript(options[:title]) unless options[:title].blank?

        # FIXME: Magic numbers from #date_or_time_select's position hash.
        select_options       = { :discard_type => true, :use_hidden => true }
        calendar_select_tag  = select_year( datetime, options_with_prefix(1, select_options))
        calendar_select_tag += select_month(datetime, options_with_prefix(2, select_options))
        calendar_select_tag += select_day(  datetime, options_with_prefix(3, select_options))

        calendar_select_tag_options = {}
        add_default_name_and_id(calendar_select_tag_options)

        calendar_select_tag += content_tag(:div, '', :id => calendar_select_tag_options["id"])

        namespace = "Rails.Calendar.#{object_name.camelize}.#{method_name.camelize}"
        calendar_select_tag += javascript_tag <<-JS
          YAHOO.namespace('#{namespace}');
          YAHOO.#{namespace}.initializeCalendar = function() {
            var theCalendar = new YAHOO.widget.Calendar('#{calendar_select_tag_options["id"]}', #{options_for_javascript(options)});

            theCalendar.render();

            theCalendar.selectEvent.subscribe(function(type, args) {
              var dates = args[0];
              var date = dates[0];

              YAHOO.util.Dom.get("#{day_dom_id}").value   = date[2];
              YAHOO.util.Dom.get("#{month_dom_id}").value = date[1];
              YAHOO.util.Dom.get("#{year_dom_id}").value  = date[0];
            });
          }

          YAHOO.util.Event.onDOMReady(YAHOO.#{namespace}.initializeCalendar);
        JS

        calendar_select_tag
      end

      private
      def year_dom_id()
        # FIXME: Magic numbers from #date_or_time_select's position hash.
        options = options_with_prefix(1, { :discard_type => true })
        name_and_id_from_options(options, 'year')
        options[:id]
      end

      def month_dom_id()
        # FIXME: Magic numbers from #date_or_time_select's position hash.
        options = options_with_prefix(2, { :discard_type => true })
        name_and_id_from_options(options, 'month')
        options[:id]
      end

      def day_dom_id()
        # FIXME: Magic numbers from #date_or_time_select's position hash.
        options = options_with_prefix(3, { :discard_type => true })
        name_and_id_from_options(options, 'day')
        options[:id]
      end

    end

    class FormBuilder
      def calendar_select(method, options = {}, html_options = {})
        @template.calendar_select(@object_name, method, options.merge(:object => @object))
      end
    end

  end
end
