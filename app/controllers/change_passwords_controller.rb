class ChangePasswordsController < ApplicationController
  before_filter :login_required
  before_filter :current_user_required

  verify :method=>:put, :only=>:update, :redirect_to=>{:action=>:edit}

  def edit
    @user = current_user
  end

  # Change password action
  def update
    @user = User.find(current_user)
    @user.old_password          = params[:user][:old_password] || ""
    @user.password              = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    
    if !@user.password.blank? && @user.save
      flash[:notice] = _("Password successfully updated.")
      redirect_to @user
    else
      flash.now[:error] = _("Your password was not changed.")
      render :action => 'edit'
    end
  end
end
