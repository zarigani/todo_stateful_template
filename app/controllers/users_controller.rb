class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  # include AuthenticatedSystem

  before_filter :not_logged_in_required,   :only => [:new, :create, :activate] 
  before_filter :login_required,           :only => [:show, :edit, :update]
  before_filter :current_user_required,    :only => [:show, :edit, :update]
  before_filter :check_administrator_role, :only => [:index, :suspend, :unsuspend, :destroy, :purge]
  # Protect these actions behind an admin login
  # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :purge]

  #Time.zone = 'UTC'
  #Time.zone = 'Tokyo'

  def index
    @users = User.find(:all)
  end

  #This show action only allows users to view their own profile
  def show
    @user = current_user
  end

  # render new.rhtml
  def new
    @user = User.new
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    if @user && @user.valid?
      @user.register!
      # Uncomment to have the user logged in after creating an account - Not Recommended
      # アカウント作成後、そのユーザーをログイン状態にするにはコメントマークを削除します - 推奨されません
      #self.current_user = @user
      flash[:notice] = _("Thanks for signing up! Please check your email to activate your account before logging in.")
      redirect_to login_path
    else
      flash.now[:error] = _("There was a problem creating your account.")
      render :action => 'new'
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = User.find(current_user)
    @user.login = params[:user] && params[:user][:login]
    @user.name  = params[:user] && params[:user][:name] || ""# DBが:default => ""のため
    if @user.changed? && @user.save
      flash[:notice] = _("Your account was successfully updated!")
      redirect_to @user
    else
      flash.now[:error] = _("Your account was not changed.")
      render :action => 'edit'
    end
  end

  def activate
    logout_keeping_session!
    @user = User.find_by_activation_code(params[:activation_code])# unless params[:activation_code].blank?
    case
    when params[:activation_code].blank?
      flash[:error] = _("The activation code was missing.  Please follow the URL from your email.")
      redirect_to new_user_path
    when !@user
      flash[:notice] = _('Activation code not found. Has your account already been activated? Plese try to log in.')
      redirect_to login_path
    when @user.active?
      flash[:notice] = _('Your account has already been activated. You can log in below.')
      redirect_to login_path
    when @user.activate! == true
      flash[:notice] = _("Your account has been activated! You can now login.")
      redirect_to login_path
    else 
      flash[:error]  = _('System error occured.')
      redirect_to login_path
    end
  end

  def suspend
    if @user.suspend! == true
      flash[:notice] = _("%{user_login} disabled") % {:user_login=>@user.login || @user.email}
    else
      flash[:error] = _("There was a problem disabling this user.")
    end
    redirect_to users_path
  end
  
  def unsuspend
    if @user.unsuspend! == true
      flash[:notice] = _("%{user_login} enabled") % {:user_login=>@user.login || @user.email}
    else
      flash[:error] = _("There was a problem enabling this user.")
    end
    redirect_to users_path
  end
  
  def destroy
    @user.delete!
    puts '**********' + @user.errors.inspect
    redirect_to users_path
  end
  
  def purge
    @user.destroy
    puts '**********' + @user.errors.inspect
    redirect_to users_path
  end
  
  # There's no page here to update or destroy a user.  If you add those, be
  # smart -- make sure you check that the visitor is authorized to do so, that they
  # supply their old password along with a new one to update it, etc.

  protected
    def find_user
      @user = User.find(params[:id])
    end
    
    # def current_user_required
    #   redirect_to :id => current_user.id if params[:id] && params[:id] =! current_user.id.to_s
    # end
end
