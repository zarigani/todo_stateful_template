$KCODE = "U"
$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'fileutils'
require 'rubygems'
require 'yaml'
require 'test/unit'
require 'active_support'
require 'action_controller'
begin
  require 'breakpoint'
rescue LoadError
#  p "breakpoint is not found."
end
require 'action_controller/test_process'
gem 'rails'
require 'initializer'

require 'gettext/rails'

ActiveSupport::Deprecation.debug = true

ActionController::Base.logger = nil
#ActionController::Base.ignore_missing_templates = false
ActionController::Routing::Routes.reload rescue nil

CACHE_DIR = 'test_cache'
# Don't change '/../temp/' cavalierly or you might hoze something you don't want hozed
FILE_STORE_PATH = File.join(File.dirname(__FILE__), 'cache', CACHE_DIR)
ActionController::Base.page_cache_directory = FILE_STORE_PATH
ActionController::Base.cache_store = :file_store, FILE_STORE_PATH
ActionController::Base.view_paths = [ File.dirname(__FILE__) + '/../fixtures/' ]
#ActionController::Base.perform_caching = true
#ActionController::Base.page_cache_directory = FILE_STORE_PATH
#ActionController::Base.fragment_cache_store = :file_store, FILE_STORE_PATH

RAILS_ROOT = File.join(File.dirname(__FILE__))

class ActionCachingTestController < ActionController::Base
  init_gettext "test"

  caches_action :index

  def index
    @cache_this = Time.now.to_f.to_s
    render :text => @cache_this
  end

  def expire
    expire_action :controller => 'action_caching_test', :action => 'index'
    render :nothing => true
  end

end

class ActionCachingMockController
  attr_accessor :mock_url_for
  attr_accessor :mock_path

  def initialize
    yield self if block_given?
  end

  def url_for(*args)
    @mock_url_for
  end

  def request
    mocked_path = @mock_path
    Object.new.instance_eval(<<-EVAL)
      def path; '#{@mock_path}' end
      self
    EVAL
  end
end

class ActionCacheTest < Test::Unit::TestCase
  def setup
    reset!
    FileUtils.mkdir_p(FILE_STORE_PATH)
    @path_class = ActionController::Caching::Actions::ActionCachePath
    @mock_controller = ActionCachingMockController.new
  end

  def teardown
    FileUtils.rm_rf(File.dirname(FILE_STORE_PATH))
  end

  def test_simple_action_cache
    get :index, :lang => "ja"
    cached_time = content_to_cache
    assert_equal cached_time, @response.body
    reset!

    get :index, :lang => "ja"
    assert_equal cached_time, @response.body
    reset!

    get :index, :lang => "en"
    cached_time_en = content_to_cache
    assert_not_equal cached_time, @response.body

    get :index, :lang => "ja"
    assert_equal cached_time, @response.body
    reset!

    get :index, :lang => "en"
    assert_equal cached_time_en, @response.body
    reset!

    get :index    # Same as en
    assert_equal cached_time_en, @response.body
  end

  def test_cache_expiration
    get :index, :lang => "ja"
    cached_time = content_to_cache
    reset!

    get :index, :lang => "ja"
    assert_equal cached_time, @response.body
    reset!

    get :index, :lang => "en"
    cached_time_en = content_to_cache
    assert_not_equal cached_time, @response.body
    reset!

    get :index, :lang => "en"
    assert_equal cached_time_en, @response.body
    reset!

    get :expire
    reset!

    get :index, :lang => "ja"
    new_cached_time = content_to_cache
    assert_not_equal cached_time, @response.body
    reset!

=begin
    get :index, :lang => "ja"
    assert_response :success
    assert_equal new_cached_time, @response.body
    reset!

    get :index, :lang => "en"
    new_cached_time_en = content_to_cache
    assert_not_equal new_cached_time, @response.body
    assert_not_equal cached_time_en, @response.body
    reset!

    get :index, :lang => "en"
    assert_response :success
    assert_equal new_cached_time_en, @response.body
    reset!
=end
  end

  def test_cache_is_scoped_by_subdomain
    @request.host = 'jamis.hostname.com'
    get :index, :lang => "ja"
    jamis_cache = content_to_cache

    reset!

    @request.host = 'david.hostname.com'
    get :index, :lang => "ja"
    david_cache = content_to_cache
    assert_not_equal jamis_cache, @response.body

    reset!

    @request.host = 'jamis.hostname.com'
    get :index, :lang => "ja"
    assert_equal jamis_cache, @response.body

    reset!

    @request.host = 'david.hostname.com'
    get :index, :lang => "ja"
    assert_equal david_cache, @response.body

    reset!

  end

  def test_xml_version_of_resource_is_treated_as_different_cache
    @mock_controller.mock_url_for = 'http://example.org/posts/'
    @mock_controller.mock_path    = '/posts/index.xml'
    path_object = @path_class.new(@mock_controller)
    assert_equal 'xml', path_object.extension
    assert_equal 'example.org/posts/index.xml', path_object.path
  end

  def test_empty_path_is_normalized
    @mock_controller.mock_url_for = 'http://example.org/'
    @mock_controller.mock_path    = '/'

    assert_equal 'example.org/index', @path_class.path_for(@mock_controller, {})
  end

  def test_file_extensions
    get :index, :id => 'kitten.jpg', :lang => "ja"
    assert_response :success
    reset!
    get :index, :id => 'kitten.jpg', :lang => "ja"
    assert_response :success
    reset!

    get :index, :id => 'kitten.jpg', :lang => "en"
    assert_response :success
    reset!
    get :index, :id => 'kitten.jpg', :lang => "en"
    assert_response :success
    reset!
  end

  private
    def content_to_cache
      assigns(:cache_this)
    end

    def reset!
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
      @controller = ActionCachingTestController.new
      @request.host = 'hostname.com'
    end

end

