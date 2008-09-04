# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  # include AuthenticatedSystem

  # render new.rhtml
  def new
  end

  def create
    user = User.authenticate(params[:login], params[:password])
    case
    when user == nil
      render_new_with_msg(_("Your username or password is incorrect."))
    when user.pending?
      render_new_with_msg(_("Your account is not active, please check your email for the activation code."))
    when user.suspended?
      render_new_with_msg(_("Your account has been disabled."))
    else
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie!(new_cookie_flag)
      flash[:notice] = _("Logged in successfully")
      redirect_back_or_default('/')
    end
  end

  # def create
  #   if user
  #     # Protects against session fixation attacks, causes request forgery
  #     # protection if user resubmits an earlier form using back
  #     # button. Uncomment if you understand the tradeoffs.
  #     # reset_session
  #     self.current_user = user
  #     new_cookie_flag = (params[:remember_me] == "1")
  #     handle_remember_cookie! new_cookie_flag
  #     redirect_back_or_default('/')
  #     flash[:notice] = "Logged in successfully"
  #   else
  #     note_failed_signin
  #     @login       = params[:login]
  #     @remember_me = params[:remember_me]
  #     render :action => 'new'
  #   end
  # end

  def destroy
    logout_killing_session!
    flash[:notice] = _("You have been logged out.")
    redirect_to login_path
  end

  # protected
  #   # Track failed login attempts
  #   def note_failed_signin
  #     flash[:error] = "Couldn't log you in as '#{params[:login]}'"
  #     logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  #   end
  
  private
    def render_new_with_msg(message)
      @login       = params[:login]
      @remember_me = params[:remember_me]
      flash.now[:error] = message
      render :action => 'new'
    end
end
