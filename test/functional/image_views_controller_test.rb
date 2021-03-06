require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

require 'image_views_controller'

# Re-raise errors caught by the controller.
class ImageViewsController; def rescue_action(e) raise e end; end

class ImageViewsControllerTest < ActionController::TestCase
  fixtures :image_views 

  def setup
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
    @controller = ImageViewsController.new
    login
    @opts =  {:controller => "image_views"} # shared across projects
  end

  def teardown
    session = nil
  end
  
  def test_login
   assert_equal "test", @p.login
  end
  
  def test_route_to_index
    opts = {:controller => 'image_views', :action => "index"}
    assert_recognizes opts , 'image_views'
    assert_routing "image_views", opts   
  end
 
  # just testing loads 
  def test_index
    get :list, @opts
    assert_response(:success)
  end

  def test_show
    @opts.update(:id => "1")
    get :show, @opts
    assert_response(:success)
  end

  def test_edit
    @opts.update(:id => "1")
    get :edit, @opts    
    assert_response(:success)
  end

  def test_new
    get :new, @opts
    assert_response(:success)
  end

end
