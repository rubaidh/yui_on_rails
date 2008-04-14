module ActionView # :nodoc:
  module Helpers # :nodoc:
    module YUI # :nodoc:
      module AssetTagHelper
        include ActionView::Helpers::AssetTagHelper
        include ActionView::Helpers::TagHelper

        STABLE_JS_COMPONENTS = [ "animation", "autocomplete", "button",
          "calendar", "colorpicker", "connection", "container", "dom",
          "dragdrop", "event", "get", "history", "imageloader", "json",
          "logger", "menu", "slider", "tabview", "treeview", "utilities",
          "yahoo", "yahoo-dom-event", "yuiloader-dom-event", "yuitest"
        ].freeze
        BETA_JS_COMPONENTS = [ "cookie", "datasource", "datatable", "editor",
          "element", "imagecropper", "layout", "profiler", "profilerviewer",
          "resize", "selector", "yuiloader"
        ].freeze
        EXPERIMENTAL_JS_COMPONENTS = ["charts", "uploader"].freeze
        JS_COMPONENTS = (STABLE_JS_COMPONENTS + BETA_JS_COMPONENTS + EXPERIMENTAL_JS_COMPONENTS).sort.freeze

        JS_COMPONENT_DEPENDENCIES = {
        }

        CSS_COMPONENTS = [ "base", "fonts", "grids", "reset", "reset-fonts", "reset-fonts-grids"]

        def yui_javascript_path(source)
          suffix = "-beta" if BETA_JS_COMPONENTS.include?(source)
          suffix = "-experimental" if EXPERIMENTAL_JS_COMPONENTS.include?(source)

          compute_public_path("#{source}#{suffix}", "yui/build/#{source}", 'js')
        end

        def yui_javascript_include(*components)
          options = components.extract_options!

          paths = components_with_dependencies(components).map do |component|
            yui_javascript_path(component)
          end

          paths << options
          javascript_include_tag(*paths)
        end

        private
        def components_with_dependencies(components)
          components.map { |component| (JS_COMPONENT_DEPENDENCIES[component] || []) + [component] }.uniq
        end
      end
    end
  end
end
