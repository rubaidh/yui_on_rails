module ActionView # :nodoc:
  module Helpers # :nodoc:
    module YUI # :nodoc:
      module CalendarHelper

        # Creates a Yahoo! UI calendar widget for the associated form date
        # field.  It will show the currently selected date and submits the
        # selected date back in a mechanism suitable for Rails to understand
        # it (ie the same way as regular +date_select+ fields are done).
        #
        # Example:
        #
        #   <% form_for @post do |f| %>
        #     <%= f.calendar_select :published_at
        #   <% end %>
        #
        # Options:
        #
        # These are some of the options that the calendar can take; see the
        # YUI developer documentation for full details.
        #
        # +title+: The title of the calendar control.  Defaults to the
        # humanized version of the field name.  If you explicitly set it to
        # blank (and don't set +close+) then the title bar will be omitted.
        def calendar_select(object_name, method, options = {}, html_options = {})
          InstanceTag.new(object_name, method, self, nil, options.delete(:object)).to_calendar_select_tag(options, html_options)
        end
      end
    end

    class InstanceTag # :nodoc:
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

        options[:selected]        = array_or_string_for_javascript(datetime.strftime("%m/%d/%Y")) unless datetime.blank?
        options[:pagedate]        = array_or_string_for_javascript(datetime.strftime("%m/%Y"))    unless datetime.blank?
        options[:title]           = array_or_string_for_javascript(options[:title]) unless options[:title].blank?
        options[:mindate]         = array_or_string_for_javascript(options[:mindate].respond_to?(:strftime) ? options[:mindate].strftime("%m/%d/%Y") : options[:mindate]) unless options[:mindate].blank?
        options[:maxdate]         = array_or_string_for_javascript(options[:maxdate].respond_to?(:strftime) ? options[:maxdate].strftime("%m/%d/%Y") : options[:maxdate]) unless options[:maxdate].blank?
        options[:locale_months]   = array_or_string_for_javascript(options[:locale_months]) unless options[:locale_months].blank?
        options[:locale_weekdays] = array_or_string_for_javascript(options[:locale_weekdays]) unless options[:locale_weekdays].blank?
        options[:nav_arrow_left]  = array_or_string_for_javascript(options[:nav_arrow_left]) unless options[:nav_arrow_left].blank?
        options[:nav_arrow_right] = array_or_string_for_javascript(options[:nav_arrow_right]) unless options[:nav_arrow_right].blank?

        hidden_date_fields + div_tag_for_calendar + javascript_tag_for_calendar(options)
      end

      private
      def calendar_div_id(options = {})
        add_default_name_and_id(options)
        options["id"]
      end

      def hidden_date_fields()
        select_options = { :discard_type => true, :use_hidden => true }

        # FIXME: Magic numbers from #date_or_time_select's position hash.
        select_year( value(object), options_with_prefix(1, select_options)) +
        select_month(value(object), options_with_prefix(2, select_options)) +
        select_day(  value(object), options_with_prefix(3, select_options))
      end

      def div_tag_for_calendar()
        content_tag(:div, '', :id => calendar_div_id)
      end

      def javascript_tag_for_calendar(options)
        namespace = "Rails.Calendar.#{object_name.camelize}.#{method_name.camelize}"
        javascript_tag <<-JS
          YAHOO.namespace('#{namespace}');
          YAHOO.#{namespace}.initializeCalendar = function() {
            var theCalendar = new YAHOO.widget.Calendar('#{calendar_div_id}', #{options_for_javascript(options)});

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
      end

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

    class FormBuilder # :nodoc:
      def calendar_select(method, options = {}, html_options = {})
        @template.calendar_select(@object_name, method, options.merge(:object => @object))
      end
    end

  end
end
