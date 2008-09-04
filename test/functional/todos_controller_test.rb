require 'test_helper'

class TodosControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:todos)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_todo
    assert_difference('Todo.count') do
      post :create, :todo => { }
    end

    assert_redirected_to todo_path(assigns(:todo))
  end

  def test_should_show_todo
    get :show, :id => todos(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => todos(:one).id
    assert_response :success
  end

  def test_should_update_todo
    put :update, :id => todos(:one).id, :todo => { }
    assert_redirected_to todo_path(assigns(:todo))
  end

  def test_should_destroy_todo
    assert_difference('Todo.count', -1) do
      delete :destroy, :id => todos(:one).id
    end

    assert_redirected_to todos_path
  end
end
