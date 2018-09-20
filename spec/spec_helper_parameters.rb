module Parameters
  module_function

  def account_id
    "http://access.auth.theplatform.com/data/Account/1"
  end

  def account_context
    "http://access.auth.theplatform.com/data/Account/1"
  end

  def web_arguments
    { 'username' => 'username', 'password' => 'password' }
  end

  def web_endpoint
    'Authentication'
  end

  def web_method
    'signIn'
  end

  def web_payload
    {}
  end

  def web_service
    'User Data Service'
  end

  def web_query
    {}
  end

  def user
    @user ||= Cts::Mpx::User.create username: 'a', password: 'b', token: 'token'
    @user
  end
end
