module ActionView # :nodoc:
  module Helpers # :nodoc:
    module YUI # :nodoc:
      module ButtonHelper
        def yui_button_link_to(name, options = {}, html_options = {})
          link_to(name, options, html_options) + javascript_tag_for_button(html_options[:id])
        end

        def yui_button_link_to_function(name, function, html_options = {})
          link_to_function(name, function, html_options) + javascript_tag_for_button(html_options[:id])
        end

        def javascript_tag_for_button(html_id)
          javascript_tag <<-JS
            YAHOO.namespace('#{html_id.camelize}');
            YAHOO.#{html_id.camelize}.initializeButton = function() {
              var button = new YAHOO.widget.Button("#{html_id}");
            };

            YAHOO.util.Event.onContentReady("bd", YAHOO.#{html_id.camelize}.initializeButton);
          JS
        end
      end
    end
  end
end