require File.dirname(__FILE__) + '/lib/authentication'
require File.dirname(__FILE__) + '/lib/authentication/by_password'
require File.dirname(__FILE__) + '/lib/authentication/by_cookie_token'
# require File.dirname(__FILE__) + '/lib/authorization'
# require File.dirname(__FILE__) + '/lib/authorization/stateful_roles'

# gem 'rubyist-aasm'#　Railsでは不要
require 'aasm'
require File.dirname(__FILE__) + '/lib/authorization/aasm_roles'

# require_dependency 'authentication'
# require_dependency 'authentication/by_password'
# require_dependency 'authentication/by_cookie_token'
# require_dependency 'authorization'
# require_dependency 'authorization/stateful_roles'
