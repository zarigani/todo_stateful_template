class UserMailer < ActionMailer::Base
  YOURSITE   = 'localhost:3000' #サーバーのURLが'http://localhost:3000/'の場合
  ADMINEMAIL = "#{USERNAME}@gmail.com"

  def signup_notification(user)
    setup_email(user)
    @subject    += _('Please activate your new account')
    @body[:url]  = "http://#{YOURSITE}/activate/#{user.activation_code}"
  
  end
  
  def activation(user)
    setup_email(user)
    @subject    += _('Your account has been activated!')
    @body[:url]  = "http://#{YOURSITE}/"
  end

  def forgot_password(user)
    setup_email(user)
    @subject    += _('You have requested to change your password')
    @body[:url]  = "http://#{YOURSITE}/reset_password/#{user.password_reset_code}"
  end

  def reset_password(user)
    setup_email(user)
    @subject    += _('Your password has been reset.')
  end  

  def change_email(user)
    setup_email(user)
    @recipients  = user.new_email
    @subject    += _('Please reset your new email')
    escape_email = URI.escape(user.new_email, Regexp.new("[^#{URI::PATTERN::ALNUM}]"))
    @body[:url]  = "http://#{YOURSITE}/reset_email/#{user.activation_code}/#{escape_email}"
  end

  def reset_email(user)
    setup_email(user)
    @subject    += _('Your email has been reset.')
  end  

  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = ADMINEMAIL
      @subject     = "[#{YOURSITE}] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end