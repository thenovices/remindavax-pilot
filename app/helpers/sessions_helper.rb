module SessionsHelper
  def login(user)
    cookies.permanent.signed[:remember_token] = [user.id, user.salt]
    self.current_user = user
  end

  def logged_in?
    !current_user.nil?
  end

  def logout
    cookies.delete(:remember_token)
    self.current_user = nil
  end

  def current_user
    @current_user ||= user_from_remember_token
  end

  def current_user=(user)
    @current_user = user
  end

  def user_from_remember_token
    User.authenticate_with_salt(*remember_token)
  end

  def remember_token
    cookies.signed[:remember_token] || [nil, nil]
  end
end
