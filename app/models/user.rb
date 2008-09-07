require 'digest/sha1'

# メールアドレスだけをログインIDにする場合は...
# - :loginの検証はすべてコメントアウト(またはlogin_required?が常にfalseを返すように設定してもOK)
# - app/views/users/_label_msg_form.html.erbの「label_msg_form.text_field :login」をコメントアウト
# - self.authenticateの「u = find_by_login_and_state(login, ['pending', 'active'])」をコメントアウト
# - self.authenticateの「u = find_by_email_and_state(login, ['pending', 'active']) unless u」を有効にする
class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  # include Authorization::StatefulRoles
  include Authorization::AasmRoles


  N_("User|Password")
  N_("User|Password confirmation")
  N_("User|Old password")
  N_("%{fn} doesn't match confirmation")
  N_("use only letters, numbers, and .-_@ please.")
  N_("should look like an email address.")
  N_('avoid non-printing characters and ＼&gt;&lt;&amp;/ please.')

  # Virtual attribute for the unencrypted password
  attr_accessor :old_password, :new_email


  validates_presence_of   :login, :if => :login_required?
  validates_length_of     :login, :if => :login_required?, :within => 3..40
  validates_uniqueness_of :login, :if => :login_required?
  validates_format_of     :login, :if => :login_required?, :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of     :name,  :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of     :name,  :maximum => 100

  validates_presence_of   :email
  validates_length_of     :email, :within => 6..100 #r@a.wk
  validates_uniqueness_of :email
  validates_format_of     :email, :with => Authentication.email_regex, :message => Authentication.bad_email_message


  def validate_on_update
    # コントローラーで params[:user][:old_password] || "" とすることで、必ず:old_passwordの入力が検証される
    errors.add(:old_password, _("古いパスワードが違っています。")) if old_password && !authenticated?(old_password)
  end

  has_many :permissions
  has_many :roles, :through => :permissions
  has_many :todos


  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation


  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  # loginまたはemailでログイン可能な設定になっている
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    # デフォルト設定
    # u = find_in_state :first, :active, :conditions => {:login => login} # need to get the salt
    
    # アクティベーション前の状態を警告する設定
    # u = find_by_login(login, :conditions => {:state => ['pending', 'active']})
    u = find_by_login_and_state(login, ['pending', 'active'])
    
    # アクティベーション前の状態を警告する設定　+ メールアドレスをログインIDにする設定
    # u = find_by_email(login, :conditions => {:state => ['pending', 'active']}) unless u
    u = find_by_email_and_state(login, ['pending', 'active']) unless u
    
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  # check_role method in lib/authticated_role.rb
  def has_role?(rolename)
    self.roles.find_by_name(rolename) ? true : false
  end


  def forgot_password
    @forgotten_password = true
    self.password_reset_code = self.class.make_token
    save
  end

  def reset_password
    @reset_password = true
    self.password_reset_code = nil
    save
  end

  def change_email
    return if new_email.blank?
    @change_email = true
    self.email = self.email_was
    self.activation_code = encrypt(new_email)
    save
  end

  def reset_email
    return unless self.activation_code == encrypt(new_email)
    @reset_email = true
    self.email = new_email
    self.activation_code = nil
    save
  end


  # Returns true if the user has just been forgotten password.
  def recently_forgot_password?
    @forgotten_password
  end

  # Returns true if the user has just been reset password.
  def recently_reset_password?
    @reset_password
  end

  def recently_change_email?
    @change_email
  end

  def recently_reset_email?
    @reset_email
  end


  def login_required?
    new_record? || login_changed?
  end

  def login_or_email
    login.blank? ? email : login
  end


  protected

    def make_activation_code
      self.deleted_at = nil
      self.activation_code = self.class.make_token
    end
end
