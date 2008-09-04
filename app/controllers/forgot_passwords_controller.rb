class ForgotPasswordsController < ApplicationController
  before_filter :not_logged_in_required

  verify :method=>:post, :only=>:create, :redirect_to=>{:action=>:new}
  verify :method=>:put, :only=>:update, :redirect_to=>{:action=>:edit}

  # Enter email address to recover password 
  def new
  end

  # Forgot password action
  def create
    # if params[:email]重要!! これがないとnilの場合、DB先頭のユーザーが代入されてしまう
    @user = User.find_by_email(params[:email], :conditions=>'activated_at IS NOT NULL') unless params[:email].blank?
    
    case
    when !@user# || !(@user.active? || @user.reset?)
      flash.now[:error] = _("Could not find a user with that email address.")
      render :action => 'new'
    # when @user.forgot_password! == true
    when @user.forgot_password
      flash[:notice] = _("A password reset link has been sent to your email address.")
      redirect_to login_path
    # when @user.reset?
    #   @user.send('forgot_password')
    #   @user.save
    #   flash[:notice] = _("A password reset link has been sent to your email address again.")
    #   redirect_to login_path
    else
      flash.now[:error] = _("A password reset link could not be sent.")
      render :action => 'new'
    end
    
    # # 入力されたメールアドレスが存在するかどうか？
    # if @user
    #   # 上記で存在した場合、イベントが実行できたかどうか？
    #   if @user.forgot_password! == true
    #     flash[:notice] = _("A password reset link has been sent to your email address.")
    #     redirect_to login_path
    #   else
    #     # 上記で実行できなかった場合、状態が:resetかどうか？
    #     if @user.reset?
    #       @user.send('forgot_password')
    #       @user.save
    #       flash[:notice] = _("A password reset link has been sent to your email address again.")
    #       redirect_to login_path
    #     else
    #       flash.now[:error] = _("A password reset link could not be sent.")
    #       render :action => 'new'
    #     end
    #   end
    # else
    #   flash.now[:error] = _("Could not find a user with that email address.")
    #   render :action => 'new'
    # end  
  end
   
  # Action triggered by clicking on the /reset_password/:id link recieved via email
  # Makes sure the id code is included
  # Checks that the id code matches a user in the database
  # Then if everything checks out, shows the password reset fields
  def edit
    # if params[:id]重要!! これがないとnilの場合、DB先頭のユーザーが代入されてしまう
    @user = User.find_by_password_reset_code(params[:id]) if params[:id]
    raise if @user.nil?
    
  rescue
    logger.error "Invalid Reset Code entered."
    flash[:notice] = _("Sorry - That is an invalid password reset code. Please check your code and try again. (Perhaps your email client inserted a carriage return?)")
    redirect_to new_forgot_password_path
  end

  # Reset password action /reset_password/:id
  # Checks once again that an id is included and makes sure that the password field isn't blank
  def update
    # if params[:id]重要!! これがないとnilの場合、DB先頭のユーザーが代入されてしまう
    @user = User.find_by_password_reset_code(params[:id]) if params[:id]
    raise if @user.nil?
    
    @user.password              = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    # password_required?を有効にして、必ずvalidationを実行するため
    @user.crypted_password      = nil
    
    # if @user.reset_password! == true
    if @user.reset_password
      flash[:notice] = _("Password reset.")
      redirect_to login_path
    else
      flash.now[:error] = _("Password mismatch.")
      render :action=>'edit', :code=>params[:code]
    end
    
  rescue
    logger.error "Cracking?"
    flash[:error] = _("Sorry - Password not reset.")
    redirect_to login_path
  end     
end
