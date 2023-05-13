require "test_helper"

class UsersSignup < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end
end

class UsersSignupTest < UsersSignup
  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: {  name: "",
                                          email: "user@invalid.com",
                                          password: "foo",
                                          password_confirmation: "bar" } }
    end
    assert_response :unprocessable_entity
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end

  test "valid signup information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: {  name: "Example User",
                                          email: "user@example.com",
                                          password: "foobar",
                                          password_confirmation: "foobar" } }
    end
    follow_redirect!
    assert_not flash.empty?
    assert_not is_logged_in?
    assert_equal 1, ActionMailer::Base.deliveries.size
  end
end

class AccountActivationTest < UsersSignup
  def setup
    super
    post users_path, params: { user: {  name: "Example User",
                                        email: "user@example.com",
                                        password: "password",
                                        password_confirmation: "password" } }

    # `assigns` allows access to instance variables in corresponding action, in this case, it gives us access to @user
    # defined in User Controller's create action.
    # Not part of Rails 5+, so we had to include assings through `rails-controller-testing` gem
    @user = assigns(:user)
  end

  test 'should not be activated' do
    assert_not @user.activated
  end

  test 'unactivated user should not be able to login' do
    log_in_as(@user)
    assert_not is_logged_in?
  end

  test 'should not be able to login with invalid activation token' do
    get edit_account_activation_path('invalid token', email: @user.email)
    assert_not is_logged_in?
  end

  test 'should not be able to login with invalid email' do
    get edit_account_activation_path(@user.activation_token, email: 'invalid_email')
    assert_not is_logged_in?
  end

  test 'should log in successfully with activation token and email' do
    get edit_account_activation_path(@user.activation_token, email: @user.email)
    assert @user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
