require "#{File.dirname(__FILE__)}/../test_helper"

# Mock out the +rails_asset_id+ method so it doesn't return different values
# every time the file mtimes are changed.
ActionView::Helpers::YUI::AssetTagHelper.module_eval do
  def rails_asset_id(source)
    nil
  end
end

class AssetTagHelperTest < Test::Unit::TestCase
  include ActionView::Helpers::YUI::AssetTagHelper

  def test_yui_javascript_path_generates_correct_paths
    STABLE_JS_COMPONENTS.each do |component|
      path = yui_javascript_path(component)
      assert_equal "/yui/build/#{component}/#{component}.js", path
      assert_file_exists "#{File.dirname(__FILE__)}/../../resources#{path}"
    end

    BETA_JS_COMPONENTS.each do |component|
      path = yui_javascript_path(component)
      assert_equal "/yui/build/#{component}/#{component}-beta.js", path
      assert_file_exists "#{File.dirname(__FILE__)}/../../resources#{path}"
    end

    EXPERIMENTAL_JS_COMPONENTS.each do |component|
      path = yui_javascript_path(component)
      assert_equal "/yui/build/#{component}/#{component}-experimental.js", path
      assert_file_exists "#{File.dirname(__FILE__)}/../../resources#{path}"
    end
  end

  def test_yui_javascript_path_generates_correct_paths_for_debug_versions
    (STABLE_JS_COMPONENTS - JS_COMPONENTS_WITHOUT_DEBUG_VERSION).each do |component|
      path = yui_javascript_path(component, :debug)
      assert_equal "/yui/build/#{component}/#{component}-debug.js", path
      assert_file_exists "#{File.dirname(__FILE__)}/../../resources#{path}"
    end

    BETA_JS_COMPONENTS.each do |component|
      path = yui_javascript_path(component, :debug)
      assert_equal "/yui/build/#{component}/#{component}-beta-debug.js", path
      assert_file_exists "#{File.dirname(__FILE__)}/../../resources#{path}"
    end

    EXPERIMENTAL_JS_COMPONENTS.each do |component|
      path = yui_javascript_path(component, :debug)
      assert_equal "/yui/build/#{component}/#{component}-experimental-debug.js", path
      assert_file_exists "#{File.dirname(__FILE__)}/../../resources#{path}"
    end

    JS_COMPONENTS_WITHOUT_DEBUG_VERSION.each do |component|
      path = yui_javascript_path(component, :debug)
      assert_equal "/yui/build/#{component}/#{component}.js", path
      assert_file_exists "#{File.dirname(__FILE__)}/../../resources#{path}"
    end
  end

  def test_yui_javascript_path_generates_correct_paths_for_minified_versions
    (STABLE_JS_COMPONENTS - JS_COMPONENTS_WITHOUT_MINIFIED_VERSION).each do |component|
      path = yui_javascript_path(component, :min)
      assert_equal "/yui/build/#{component}/#{component}-min.js", path
      assert_file_exists "#{File.dirname(__FILE__)}/../../resources#{path}"
    end

    BETA_JS_COMPONENTS.each do |component|
      path = yui_javascript_path(component, :min)
      assert_equal "/yui/build/#{component}/#{component}-beta-min.js", path
      assert_file_exists "#{File.dirname(__FILE__)}/../../resources#{path}"
    end

    EXPERIMENTAL_JS_COMPONENTS.each do |component|
      path = yui_javascript_path(component, :min)
      assert_equal "/yui/build/#{component}/#{component}-experimental-min.js", path
      assert_file_exists "#{File.dirname(__FILE__)}/../../resources#{path}"
    end

    JS_COMPONENTS_WITHOUT_MINIFIED_VERSION.each do |component|
      path = yui_javascript_path(component, :min)
      assert_equal "/yui/build/#{component}/#{component}.js", path
      assert_file_exists "#{File.dirname(__FILE__)}/../../resources#{path}"
    end
  end

  def test_yui_javascript_include_inserts_correct_script_tags
    assert_dom_equal %(<script type="text/javascript" src="/yui/build/yahoo/yahoo.js"></script>), yui_javascript_include(:yahoo)
    assert_dom_equal [
      %(<script type="text/javascript" src="/yui/build/yahoo/yahoo.js"></script>),
      %(<script type="text/javascript" src="/yui/build/utilities/utilities.js"></script>)
    ].join("\n"), yui_javascript_include(:yahoo, :utilities)
  end

  def test_yui_javascript_include_inserts_correct_script_tags_with_dependencies
    assert_dom_equal [
      %(<script type="text/javascript" src="/yui/build/yahoo/yahoo.js"></script>),
      %(<script type="text/javascript" src="/yui/build/dom/dom.js"></script>),
      %(<script type="text/javascript" src="/yui/build/event/event.js"></script>),
      %(<script type="text/javascript" src="/yui/build/animation/animation.js"></script>)
    ].join("\n"), yui_javascript_include(:animation)

    assert_dom_equal [
      %(<script type="text/javascript" src="/yui/build/yahoo/yahoo.js"></script>),
      %(<script type="text/javascript" src="/yui/build/dom/dom.js"></script>),
      %(<script type="text/javascript" src="/yui/build/event/event.js"></script>),
      %(<script type="text/javascript" src="/yui/build/container/container.js"></script>),
      %(<script type="text/javascript" src="/yui/build/menu/menu.js"></script>),
      %(<script type="text/javascript" src="/yui/build/element/element-beta.js"></script>),
      %(<script type="text/javascript" src="/yui/build/button/button.js"></script>),
      %(<script type="text/javascript" src="/yui/build/editor/editor-beta.js"></script>)
    ].join("\n"), yui_javascript_include(:editor)
  end

  def test_dependencies_for_component
    assert_equal [], dependencies_for_component("yahoo")
    assert_equal ["yahoo"], dependencies_for_component("dom")
    assert_equal ["yahoo", "dom", "event"], dependencies_for_component("animation")
    assert_equal ["yahoo", "dom", "event", "container", "menu", "element", "button"], dependencies_for_component("editor")
  end

  def test_component_with_dependencies
    assert_equal ["yahoo"],                                                                     component_with_dependencies("yahoo")
    assert_equal ["yahoo", "dom"],                                                              component_with_dependencies("dom")
    assert_equal ["yahoo", "dom", "event", "animation"],                                        component_with_dependencies("animation")
    assert_equal ["yahoo", "dom", "event", "container", "menu", "element", "button", "editor"], component_with_dependencies("editor")
  end

  def test_components_with_dependencies
    assert_equal ["yahoo"],                                                                     components_with_dependencies("yahoo")
    assert_equal ["yahoo", "dom"],                                                              components_with_dependencies("dom")
    assert_equal ["yahoo", "dom", "event", "animation"],                                        components_with_dependencies("animation")
    assert_equal ["yahoo", "dom", "event", "container", "menu", "element", "button", "editor"], components_with_dependencies("editor")

    assert_equal ["yahoo", "dom", "event", "animation", "container", "menu", "element", "button", "editor"], components_with_dependencies(["animation", "editor"])
    assert_equal ["yahoo", "dom", "event", "container", "menu", "element", "button", "editor", "animation"], components_with_dependencies(["editor", "animation"])
    assert_equal ["yahoo", "dom", "event", "animation", "container", "menu", "element", "button", "editor"], components_with_dependencies(["dom", "animation", "editor"])
  end

  private
  def assert_file_exists(file)
    assert File.exists?(file), "File #{file} does not exist."
  end
end