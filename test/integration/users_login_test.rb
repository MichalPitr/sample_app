require "test_helper"

class UsersLogin < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end
end

class InvalidPasswordTest < UsersLogin
  test "login path" do
    get login_path
    assert_template 'sessions/new'
  end

  test "login with valid email and invalid password information" do
    post login_path, params: { session: { email: "michael@example.com", password: "invalid" } }
    assert_not is_logged_in?
    assert_response :unprocessable_entity
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end
end

class ValidLogin < UsersLogin
  def setup
    super
    post login_path, params: { session: { email: @user.email, password: 'password' }}
  end
end

class ValidLoginTest < ValidLogin
  test "valid login" do
    assert is_logged_in?
    assert_redirected_to root_path
  end

  # tests within a class are run in order
  test "redirect after login" do
    follow_redirect!
    assert_template 'static_pages/_home_logged_in'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end
end

class Logout < ValidLogin
  def setup
    super
    delete logout_path
  end

  test "successful logout" do
    assert_not is_logged_in?
    assert_response :see_other
    assert_redirected_to root_url
  end

  test "redirected after logout" do
    follow_redirect!
    assert_template "static_pages/home"
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test 'should still work after logout in another window' do
    delete logout_path
    assert_redirected_to root_url
  end
end

class RememberingTest < UsersLogin
  test 'authenticated? should return false for user with nil digest' do
    assert_not @user.authenticated?(:remember, '')
  end

  test 'login with remembering' do
    log_in_as(@user, remember_me: '1')
    assert_equal cookies[:remember_token], assigns(:user).remember_token
  end

  test 'login without remembering' do
    log_in_as(@user, remember_me: '1')
    # Re-log in to make sure logging in without remember removes the token
    log_in_as(@user, remember_me: '0')
    assert cookies[:remember_token].blank?
  end
end
