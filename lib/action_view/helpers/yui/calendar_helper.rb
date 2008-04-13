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
        defaults = { :discard_type => true }
        options = defaults.merge(options)

        datetime = value(object)

        calendar_select_tag = select_year(datetime, options_with_prefix(1, options.merge(:use_hidden => true)), html_options)
        calendar_select_tag += select_month(datetime, options_with_prefix(2, options.merge(:use_hidden => true)), html_options)
        calendar_select_tag += select_day(datetime, options_with_prefix(3, options.merge(:use_hidden => true)), html_options)

        add_default_name_and_id(options)

        calendar_select_tag += content_tag(:div, '', :id => options["id"])

        namespace = "Rails.Calendar.#{object_name.camelize}.#{method_name.camelize}"
        calendar_select_tag += javascript_tag <<-JS
          YAHOO.namespace('#{namespace}');
          YAHOO.#{namespace}.initializeCalendar = function() {

            var day        = YAHOO.util.Dom.get("#{day_dom_id(options)}").value;
            var month      = YAHOO.util.Dom.get("#{month_dom_id(options)}").value;
            var year       = YAHOO.util.Dom.get("#{year_dom_id(options)}").value;
            var dateString = month + "/" + day + "/" + year;

            var theCalendar = new YAHOO.widget.Calendar('#{options["id"]}', {
              navigator: true,
              start_weekday: 1,
              selected: dateString
            });

            theCalendar.render();

            theCalendar.selectEvent.subscribe(function(type, args) {
              var dates = args[0];
              var date = dates[0];

              var dayField   = YAHOO.util.Dom.get("#{day_dom_id(options)}");
              var monthField = YAHOO.util.Dom.get("#{month_dom_id(options)}");
              var yearField  = YAHOO.util.Dom.get("#{year_dom_id(options)}");

              var day   = date[2];
              var month = date[1];
              var year  = date[0];

              dayField.value   = day;
              monthField.value = month;
              yearField.value  = year;
            });
          }

          YAHOO.util.Event.onDOMReady(YAHOO.#{namespace}.initializeCalendar);
        JS

        calendar_select_tag
      end

      private
      def year_dom_id(options = {})
        # FIXME: Magic numbers from #date_or_time_select's position hash.
        options = options_with_prefix(1, options)
        name_and_id_from_options(options, 'year')
        options[:id]
      end

      def month_dom_id(options = {})
        # FIXME: Magic numbers from #date_or_time_select's position hash.
        options = options_with_prefix(2, options)
        name_and_id_from_options(options, 'month')
        options[:id]
      end

      def day_dom_id(options = {})
        # FIXME: Magic numbers from #date_or_time_select's position hash.
        options = options_with_prefix(3, options)
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
