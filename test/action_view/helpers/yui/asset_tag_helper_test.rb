require "#{File.dirname(__FILE__)}/../../../test_helper"

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
      assert_yui_file_exists path
    end

    BETA_JS_COMPONENTS.each do |component|
      path = yui_javascript_path(component)
      assert_equal "/yui/build/#{component}/#{component}-beta.js", path
      assert_yui_file_exists path
    end

    EXPERIMENTAL_JS_COMPONENTS.each do |component|
      path = yui_javascript_path(component)
      assert_equal "/yui/build/#{component}/#{component}-experimental.js", path
      assert_yui_file_exists path
    end
  end

  def test_yui_javascript_path_generates_correct_paths_for_debug_versions
    (STABLE_JS_COMPONENTS - JS_COMPONENTS_WITHOUT_DEBUG_VERSION).each do |component|
      path = yui_javascript_path(component, :debug)
      assert_equal "/yui/build/#{component}/#{component}-debug.js", path
      assert_yui_file_exists path
    end

    BETA_JS_COMPONENTS.each do |component|
      path = yui_javascript_path(component, :debug)
      assert_equal "/yui/build/#{component}/#{component}-beta-debug.js", path
      assert_yui_file_exists path
    end

    EXPERIMENTAL_JS_COMPONENTS.each do |component|
      path = yui_javascript_path(component, :debug)
      assert_equal "/yui/build/#{component}/#{component}-experimental-debug.js", path
      assert_yui_file_exists path
    end

    JS_COMPONENTS_WITHOUT_DEBUG_VERSION.each do |component|
      path = yui_javascript_path(component, :debug)
      assert_equal "/yui/build/#{component}/#{component}.js", path
      assert_yui_file_exists path
    end
  end

  def test_yui_javascript_path_generates_correct_paths_for_minified_versions
    (STABLE_JS_COMPONENTS - JS_COMPONENTS_WITHOUT_MINIFIED_VERSION).each do |component|
      path = yui_javascript_path(component, :min)
      assert_equal "/yui/build/#{component}/#{component}-min.js", path
      assert_yui_file_exists path
    end

    BETA_JS_COMPONENTS.each do |component|
      path = yui_javascript_path(component, :min)
      assert_equal "/yui/build/#{component}/#{component}-beta-min.js", path
      assert_yui_file_exists path
    end

    EXPERIMENTAL_JS_COMPONENTS.each do |component|
      path = yui_javascript_path(component, :min)
      assert_equal "/yui/build/#{component}/#{component}-experimental-min.js", path
      assert_yui_file_exists path
    end

    JS_COMPONENTS_WITHOUT_MINIFIED_VERSION.each do |component|
      path = yui_javascript_path(component, :min)
      assert_equal "/yui/build/#{component}/#{component}.js", path
      assert_yui_file_exists path
    end
  end

  def test_yui_javascript_include_tag_inserts_correct_script_tags
    assert_dom_equal %(<script type="text/javascript" src="/yui/build/yahoo/yahoo.js"></script>), yui_javascript_include_tag(:yahoo)
    assert_dom_equal [
      %(<script type="text/javascript" src="/yui/build/yahoo/yahoo.js"></script>),
      %(<script type="text/javascript" src="/yui/build/utilities/utilities.js"></script>)
    ].join("\n"), yui_javascript_include_tag(:yahoo, :utilities)
  end

  def test_yui_javascript_include_tag_inserts_correct_script_tags_with_dependencies
    assert_dom_equal [
      %(<script type="text/javascript" src="/yui/build/yahoo/yahoo.js"></script>),
      %(<script type="text/javascript" src="/yui/build/dom/dom.js"></script>),
      %(<script type="text/javascript" src="/yui/build/event/event.js"></script>),
      %(<script type="text/javascript" src="/yui/build/animation/animation.js"></script>)
    ].join("\n"), yui_javascript_include_tag(:animation)

    assert_dom_equal [
      %(<script type="text/javascript" src="/yui/build/yahoo/yahoo.js"></script>),
      %(<script type="text/javascript" src="/yui/build/dom/dom.js"></script>),
      %(<script type="text/javascript" src="/yui/build/event/event.js"></script>),
      %(<script type="text/javascript" src="/yui/build/container/container.js"></script>),
      %(<script type="text/javascript" src="/yui/build/menu/menu.js"></script>),
      %(<script type="text/javascript" src="/yui/build/element/element-beta.js"></script>),
      %(<script type="text/javascript" src="/yui/build/button/button.js"></script>),
      %(<script type="text/javascript" src="/yui/build/editor/editor-beta.js"></script>),
      %(<link href="/yui/build/editor/assets/skins/sam/editor.css" rel="stylesheet" type="text/css" media="screen" />)
    ].join("\n"), yui_javascript_include_tag(:editor)
  end

  def test_yui_javascript_include_tag_also_includes_component_stylesheets
    assert_dom_equal [
      %(<script type="text/javascript" src="/yui/build/yahoo/yahoo.js"></script>),
      %(<script type="text/javascript" src="/yui/build/dom/dom.js"></script>),
      %(<script type="text/javascript" src="/yui/build/event/event.js"></script>),
      %(<script type="text/javascript" src="/yui/build/autocomplete/autocomplete.js"></script>),
      %(<link href="/yui/build/autocomplete/assets/skins/sam/autocomplete.css" rel="stylesheet" type="text/css" media="screen" />)
    ].join("\n"), yui_javascript_include_tag(:autocomplete)
  end

  def test_dependencies_for_component
    assert_equal [],                                                                  yui_dependencies_for_component("yahoo",     JS_COMPONENT_DEPENDENCIES)
    assert_equal ["yahoo"],                                                           yui_dependencies_for_component("dom",       JS_COMPONENT_DEPENDENCIES)
    assert_equal ["yahoo", "dom", "event"],                                           yui_dependencies_for_component("animation", JS_COMPONENT_DEPENDENCIES)
    assert_equal ["yahoo", "dom", "event", "container", "menu", "element", "button"], yui_dependencies_for_component("editor",    JS_COMPONENT_DEPENDENCIES)
  end

  def test_component_with_dependencies
    assert_equal ["yahoo"],                                                                     yui_component_with_dependencies("yahoo",     JS_COMPONENT_DEPENDENCIES)
    assert_equal ["yahoo", "dom"],                                                              yui_component_with_dependencies("dom",       JS_COMPONENT_DEPENDENCIES)
    assert_equal ["yahoo", "dom", "event", "animation"],                                        yui_component_with_dependencies("animation", JS_COMPONENT_DEPENDENCIES)
    assert_equal ["yahoo", "dom", "event", "container", "menu", "element", "button", "editor"], yui_component_with_dependencies("editor",    JS_COMPONENT_DEPENDENCIES)
  end

  def test_components_with_dependencies
    assert_equal ["yahoo"],                                                                     yui_components_with_dependencies("yahoo",     JS_COMPONENT_DEPENDENCIES)
    assert_equal ["yahoo", "dom"],                                                              yui_components_with_dependencies("dom",       JS_COMPONENT_DEPENDENCIES)
    assert_equal ["yahoo", "dom", "event", "animation"],                                        yui_components_with_dependencies("animation", JS_COMPONENT_DEPENDENCIES)
    assert_equal ["yahoo", "dom", "event", "container", "menu", "element", "button", "editor"], yui_components_with_dependencies("editor",    JS_COMPONENT_DEPENDENCIES)

    assert_equal ["yahoo", "dom", "event", "animation", "container", "menu", "element", "button", "editor"], yui_components_with_dependencies(["animation", "editor"],        JS_COMPONENT_DEPENDENCIES)
    assert_equal ["yahoo", "dom", "event", "container", "menu", "element", "button", "editor", "animation"], yui_components_with_dependencies(["editor", "animation"],        JS_COMPONENT_DEPENDENCIES)
    assert_equal ["yahoo", "dom", "event", "animation", "container", "menu", "element", "button", "editor"], yui_components_with_dependencies(["dom", "animation", "editor"], JS_COMPONENT_DEPENDENCIES)
  end

  def test_yui_stylesheet_path_generates_correct_paths
    CSS_COMPONENTS.each do |component|
      path = yui_stylesheet_path(component)
      assert_equal "/yui/build/#{component}/#{component}.css", path
      assert_yui_file_exists path
    end
  end

  def test_yui_stylesheet_path_generates_correct_paths_for_minified_versions
    (CSS_COMPONENTS - CSS_COMPONENTS_WITHOUT_MINIFIED_VERSION).each do |component|
      path = yui_stylesheet_path(component, :min)
      assert_equal "/yui/build/#{component}/#{component}-min.css", path
      assert_yui_file_exists path
    end

    CSS_COMPONENTS_WITHOUT_MINIFIED_VERSION.each do |component|
      path = yui_stylesheet_path(component, :min)
      assert_equal "/yui/build/#{component}/#{component}.css", path
      assert_yui_file_exists path
    end
  end

  def test_yui_js_stylesheet_path_generates_correct_paths
    JS_COMPONENTS_WITH_CSS.each do |component|
      path = yui_js_stylesheet_path(component)
      assert_equal "/yui/build/#{component}/assets/skins/sam/#{component}.css", path
      assert_yui_file_exists path
    end
  end

  def test_yui_stylesheet_link_tag_inserts_correct_link_tags
    assert_dom_equal [
      %(<link  type="text/css" rel="stylesheet" href="/yui/build/base/base.css" media="screen" />)
    ].join("\n"), yui_stylesheet_link_tag(:base)

    assert_dom_equal [
      %(<link  type="text/css" rel="stylesheet" href="/yui/build/reset/reset.css" media="screen" />),
      %(<link  type="text/css" rel="stylesheet" href="/yui/build/base/base.css" media="screen" />)
    ].join("\n"), yui_stylesheet_link_tag(:reset, :base)
  end

  def test_yui_stylesheet_link_tag_inserts_correct_link_tags_with_dependencies
    assert_dom_equal [
      %(<link  type="text/css" rel="stylesheet" href="/yui/build/fonts/fonts.css" media="screen" />),
      %(<link  type="text/css" rel="stylesheet" href="/yui/build/grids/grids.css" media="screen" />)
    ].join("\n"), yui_stylesheet_link_tag(:grids)
  end

  def test_yui_stylesheet_link_tag_passes_media_options_through
    assert_dom_equal [
      %(<link  type="text/css" rel="stylesheet" href="/yui/build/base/base.css" media="print" />)
    ].join("\n"), yui_stylesheet_link_tag(:base, :media => :print)
  end

  private
  def assert_yui_file_exists(file)
    assert_file_exists "#{PLUGIN_ROOT}/resources#{file}"
  end

  def assert_file_exists(file)
    assert File.exists?(file), "File #{file} does not exist."
  end
end