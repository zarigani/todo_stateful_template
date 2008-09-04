USERNAME = 'xxxxxx' #@gmail.comを除くユーザー名を設定
PASSWORD = 'xxxxxx' #パスワードを設定

require "smtp_tls"

#ActionMailer::Base.delivery_method = :sendmail
# デフォルトは:smtpなので以下の設定は不要
# ActionMailer::Base.delivery_method = :smtp #コメントであっても、このように記述するとエラーになる
ActionMailer::Base.smtp_settings = {
  :address => "smtp.gmail.com",
  :port => 587,
  :domain => "www.example-domain.com",
  :authentication => :login,
  :user_name => USERNAME,
  :password => PASSWORD
}
