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
    stable_js_components = [ "animation", "autocomplete",
      "button", "calendar", "colorpicker", "connection",
      "container", "dom",
      "dragdrop", "event", "get",
      "history", "imageloader", "json",
      "logger", "menu",
      "slider",
      "tabview", "treeview", "utilities", "yahoo",
      "yahoo-dom-event", "yuiloader-dom-event", "yuitest"
    ]
    beta_js_components = [ "cookie", "datasource", "datatable", "editor",
      "element", "imagecropper", "layout", "profiler", "profilerviewer",
      "resize", "selector", "yuiloader"
    ]
    experimental_js_components = ["charts", "uploader"]

    stable_js_components.each do |component|
      path = yui_javascript_path(component)
      assert_equal "/yui/build/#{component}/#{component}.js", path
      assert_file_exists "#{File.dirname(__FILE__)}/../../resources#{path}"
    end

    beta_js_components.each do |component|
      path = yui_javascript_path(component)
      assert_equal "/yui/build/#{component}/#{component}-beta.js", path
      assert_file_exists "#{File.dirname(__FILE__)}/../../resources#{path}"
    end

    experimental_js_components.each do |component|
      path = yui_javascript_path(component)
      assert_equal "/yui/build/#{component}/#{component}-experimental.js", path
      assert_file_exists "#{File.dirname(__FILE__)}/../../resources#{path}"
    end
  end

  def test_yui_javascript_include_inserts_correct_script_tags
    assert_dom_equal %(<script type="text/javascript" src="/yui/build/animation/animation.js"></script>), yui_javascript_include(:animation)
    assert_dom_equal %(<script type="text/javascript" src="/yui/build/animation/animation.js"></script>\n<script type="text/javascript" src="/yui/build/autocomplete/autocomplete.js"></script>), yui_javascript_include(:animation, :autocomplete)
  end
  private
  def assert_file_exists(file)
    assert File.exists?(file), "File #{file} does not exist."
  end
end