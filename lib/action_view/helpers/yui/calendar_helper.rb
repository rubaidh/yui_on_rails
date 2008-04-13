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
      def to_calendar_select_tag(options = {}, html_options = {})
        "Hello World."
      end
    end

    class FormBuilder
      def calendar_select(method, options = {}, html_options = {})
        @template.calendar_select(@object_name, method, options.merge(:object => @object))
      end
    end

  end
end
