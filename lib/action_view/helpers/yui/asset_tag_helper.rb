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
        JS_COMPONENTS_WITHOUT_DEBUG_VERSION    = ["utilities", "yahoo-dom-event", "yuiloader-dom-event"]
        JS_COMPONENTS_WITHOUT_MINIFIED_VERSION = ["utilities", "yahoo-dom-event", "yuiloader-dom-event"]

        JS_COMPONENTS_WITH_CSS = [
          "autocomplete",
          "button",
          "calendar",
          "colorpicker",
          "container",
          "datatable",
          "editor",
          "imagecropper",
          "layout",
          "logger",
          "menu",
          "profilerviewer",
          "resize",
          "tabview",
          "treeview",
          "yuitest"
        ]

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
        CSS_COMPONENTS_WITHOUT_MINIFIED_VERSION = [ "reset-fonts", "reset-fonts-grids"]
        CSS_COMPONENT_DEPENDENCIES = {
          "base"              => [],
          "fonts"             => [],
          "grids"             => ["fonts"],
          "reset"             => [],
          "reset-fonts"       => [],
          "reset-fonts-grids" => []
        }

        def yui_javascript_path(source, version = nil)
          suffix = ""
          suffix += "-beta"         if BETA_JS_COMPONENTS.include?(source)
          suffix += "-experimental" if EXPERIMENTAL_JS_COMPONENTS.include?(source)
          suffix += "-debug"        if "#{version}" == "debug" && !JS_COMPONENTS_WITHOUT_DEBUG_VERSION.include?(source)
          suffix += "-min"          if "#{version}" == "min"   && !JS_COMPONENTS_WITHOUT_MINIFIED_VERSION.include?(source)

          compute_public_path("#{source}#{suffix}", "yui/build/#{source}", 'js')
        end

        def yui_javascript_include_tag(*components)
          options = components.extract_options!

          # Stringify components
          components = components.map { |c| c.to_s }

          paths = yui_js_components_with_dependencies(components).map do |component|
            yui_javascript_path(component, Rails.env.development? ? "debug" : "min")
          end

          component_stylesheets = components.select do |component|
            JS_COMPONENTS_WITH_CSS.include?(component)
          end

          returning [] do |html|
            paths << options
            html << javascript_include_tag(*paths)
            unless component_stylesheets.blank?
              stylesheet_paths = component_stylesheets.map do |component_stylesheet|
                yui_js_stylesheet_path(component_stylesheet)
              end
              stylesheet_paths << options
              html << stylesheet_link_tag(*stylesheet_paths)
            end
          end.join("\n")
        end

        def yui_js_components_with_dependencies(components)
          yui_components_with_dependencies(components, JS_COMPONENT_DEPENDENCIES)
        end

        def yui_css_components_with_dependencies(components)
          yui_components_with_dependencies(components, CSS_COMPONENT_DEPENDENCIES)
        end

        def yui_components_with_dependencies(components, dependency_list)
          components.map { |c| yui_component_with_dependencies(c, dependency_list) }.flatten.uniq
        end

        def yui_component_with_dependencies(component, dependency_list)
          yui_dependencies_for_component(component, dependency_list) + [component]
        end

        def yui_dependencies_for_component(component, dependency_list)
          dependency_list[component] || []
        end

        def yui_js_stylesheet_path(source)
          compute_public_path(source, "yui/build/#{source}/assets/skins/sam", 'css')
        end

        def yui_stylesheet_path(source, version = nil)
          suffix = "-min" if "#{version}" == "min" && !CSS_COMPONENTS_WITHOUT_MINIFIED_VERSION.include?(source)
          compute_public_path("#{source}#{suffix}", "yui/build/#{source}", 'css')
        end

        def yui_stylesheet_link_tag(*components)
          options = components.extract_options!

          # Stringify components
          components = components.map { |c| c.to_s }

          paths = yui_css_components_with_dependencies(components).map do |component|
            yui_stylesheet_path(component, Rails.env.development? ? nil : "min")
          end
          paths << options
          stylesheet_link_tag(*paths)
        end
      end
    end
  end
end
