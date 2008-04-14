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
        JS_COMPONENTS_WITHOUT_DEBUG_VERSION =    ["utilities", "yahoo-dom-event", "yuiloader-dom-event"]
        JS_COMPONENTS_WITHOUT_MINIFIED_VERSION = ["utilities", "yahoo-dom-event", "yuiloader-dom-event"]

        # All the dependencies of each YUI component.  This is cribbed from
        # playing around with:
        #
        #   http://developer.yahoo.com/yui/articles/hosting/#configure
        JS_COMPONENT_DEPENDENCIES = {
          "animation"           => ["yahoo", "dom", "event"],
          "autocomplete"        => ["yahoo", "dom", "event"],
          "button"              => ["yahoo", "dom", "event", "element"],
          "calendar"            => ["yahoo", "dom", "event"],
          "charts"              => ["yahoo", "dom", "event", "element", "json", "datasource"],
          "colorpicker"         => ["yahoo", "dom", "event", "dragdrop", "slider", "element"],
          "connection"          => ["yahoo", "event", "connection"],
          "container"           => ["yahoo", "dom", "event"],
          "cookie"              => ["yahoo"],
          "datasource"          => ["yahoo", "event"],
          "datatable"           => ["yahoo", "dom", "event", "element", "datasource"],
          "dom"                 => ["yahoo"],
          "dragdrop"            => ["yahoo", "dom", "event"],
          "editor"              => ["yahoo", "dom", "event", "container", "menu", "element", "button"],
          "element"             => ["yahoo", "dom", "event"],
          "event"               => ["yahoo"],
          "get"                 => ["yahoo"],
          "history"             => ["yahoo", "event"],
          "imagecropper"        => ["yahoo", "dom", "event", "dragdrop", "element", "resize"],
          "imageloader"         => ["yahoo", "dom", "event"],
          "json"                => ["yahoo"],
          "layout"              => ["yahoo", "dom", "event", "element"],
          "logger"              => ["yahoo", "dom", "event"],
          "menu"                => ["yahoo", "dom", "event", "container"],
          "profiler"            => ["yahoo"],
          "profilerviewer"      => ["yuiloader", "profiler", "dom", "event", "element"],
          "resize"              => ["yahoo", "dom", "event", "dragdrop", "element"],
          "selector"            => ["yahoo", "dom"],
          "slider"              => ["yahoo", "dom", "event", "dragdrop"],
          "tabview"             => ["yahoo", "dom", "event", "element"],
          "treeview"            => ["yahoo", "event"],
          "uploader"            => ["yahoo"],
          "utilities"           => [],
          "yahoo"               => [],
          "yahoo-dom-event"     => [],
          "yuiloader"           => [],
          "yuiloader-dom-event" => [],
          "yuitest"             => ["yahoo", "dom", "event", "logger", "yuitest"]
        }

        CSS_COMPONENTS = [ "base", "fonts", "grids", "reset", "reset-fonts", "reset-fonts-grids"]

        def yui_javascript_path(source, version = nil)
          suffix = ""
          suffix += "-beta"         if BETA_JS_COMPONENTS.include?(source)
          suffix += "-experimental" if EXPERIMENTAL_JS_COMPONENTS.include?(source)
          suffix += "-debug"        if "#{version}" == "debug" && !JS_COMPONENTS_WITHOUT_DEBUG_VERSION.include?(source)
          suffix += "-min"          if "#{version}" == "min"   && !JS_COMPONENTS_WITHOUT_MINIFIED_VERSION.include?(source)

          compute_public_path("#{source}#{suffix}", "yui/build/#{source}", 'js')
        end

        def yui_javascript_include(*components)
          options = components.extract_options!

          # Stringify components
          components = components.map { |c| c.to_s }

          paths = components_with_dependencies(components).map do |component|
            yui_javascript_path(component)
          end

          paths << options
          javascript_include_tag(*paths)
        end

        def components_with_dependencies(components)
          components.map { |c| component_with_dependencies(c) }.flatten.uniq
        end

        def component_with_dependencies(component)
          dependencies_for_component(component) + [component]
        end

        def dependencies_for_component(component)
          JS_COMPONENT_DEPENDENCIES[component] || []
        end
      end
    end
  end
end
