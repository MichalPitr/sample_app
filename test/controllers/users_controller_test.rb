require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test 'should get new' do
    get signup_path
    assert_response :success
  end

  test 'should redirect to index when not logged in' do
    get users_path
    assert_redirected_to login_url
  end

  test 'should redirect from edit to login when not logged in' do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should redirect from update to login when not logged in' do
    patch user_path(@user), params: { user: { name: @user.name, email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should redirect from edit to root when logged in as the wrong user' do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test 'should redirect from update to root when updating as the wrong user' do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name, email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test 'should not allow the admin attribute to be editable via web' do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@other_user), params: { user: { password: 'password',
                                                    password_confirmation: 'password',
                                                    admin: true }}
    assert_not @other_user.reload.admin?
  end

  test 'should redirect destroy when not logged in' do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to login_url
  end

  test 'should redirect destroy to home when not logged in as admin' do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to root_url
  end

  test 'should delete a user when logged in as admin' do
    log_in_as(@user)
    assert_difference 'User.count', -1 do
      delete user_path(@other_user)
    end
    assert_response :see_other
    assert_redirected_to users_url
  end

  test 'should redirect following when not logged in' do
    get following_user_path(@user)
    assert_redirected_to login_url
  end

  test 'should redirect followers when not logged in' do
    get following_user_path(@user)
    assert_redirected_to login_url
  end
end
