class ChangeEmailsController < ApplicationController
  before_filter :login_required
  before_filter :current_user_required

  verify :method=>:put, :only=>:update, :redirect_to=>{:action=>:edit}

  # Change email action
  def edit
    @user = current_user
  end

  # Submit new email
  def update
    @user = User.find(current_user)
    @user.new_email = @user.email = params[:user][:email]
    case
    when @user.valid? && @user.email_changed?# @user.change_email! == true
      @user.change_email
      flash[:notice] = _("A email reset link has been sent to your email address.")
      redirect_to @user
    else
      flash.now[:error] = _("Your email was not changed.")
      render :action => 'edit'
    end
  end

  # activate new email
  def show
    @user = User.find_by_activation_code(params[:code]) unless params[:code].blank?
    @user.new_email = params[:new_email] if @user
    case
    when !@user
      flash[:error]  = _('Invalid email reset URL.')
      redirect_to login_path
    when !(@user == current_user)
      logout_keeping_session!
      flash[:error]  = _('Another account logged in. You must log in.')
      redirect_to login_path
    when @user.reset_email# @user.activate! == true
      flash[:notice] = _("Your email has been reset!")
      redirect_to @user
    else 
      flash[:error]  = _('Invalid email.')
      redirect_to @user
    end
  end
end
