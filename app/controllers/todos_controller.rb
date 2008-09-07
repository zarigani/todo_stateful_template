class TodosController < ApplicationController
  before_filter :login_required
  before_filter :current_user_required

  # GET /todos
  # GET /todos.xml
  def index
    @todos = current_user.todos

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @todos }
    end
  end

  # GET /todos/1
  # GET /todos/1.xml
  def show
    @todo = current_user.todos.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @todo }
    end
  end

  # GET /todos/new
  # GET /todos/new.xml
  def new
    @todo = Todo.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @todo }
    end
  end

  # GET /todos/1/edit
  def edit
    @todo = current_user.todos.find(params[:id])
  end

  # POST /todos
  # POST /todos.xml
  def create
    @todo = Todo.new(params[:todo])

    respond_to do |format|
      if current_user.todos << @todo
        flash[:notice] = 'Todo was successfully created.'
        format.html { redirect_to([current_user, @todo]) }
        format.xml  { render :xml => @todo, :status => :created, :location => [current_user, @todo] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @todo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /todos/1
  # PUT /todos/1.xml
  def update
    @todo = current_user.todos.find(params[:id])

    respond_to do |format|
      if @todo.update_attributes(params[:todo])
        flash[:notice] = 'Todo was successfully updated.'
        format.html { redirect_to([current_user, @todo]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @todo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /todos/1
  # DELETE /todos/1.xml
  def destroy
    @todo = current_user.todos.find(params[:id])
    @todo.destroy

    respond_to do |format|
      format.html { redirect_to(user_todos_url) }
      format.xml  { head :ok }
    end
  end
end
