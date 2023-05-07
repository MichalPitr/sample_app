require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test 'unsuccessful edit' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    # missing name, invalid email address, too short password, non-matching password
    patch user_path(@user), params: { user: { name: '',
                                              email: 'email@invalid',
                                              password: 'foo',
                                              password_confirmation: 'bar' } }
    assert_template 'users/edit'
    assert_select '.alert', text: 'The form contains 4 errors.'
  end

  test 'successful edit' do
    log_in_as(@user)

    get edit_user_path(@user)
    assert_template 'users/edit'
    name = 'Foo Bar'
    email = 'foo@bar.com'
    res = patch user_path(@user), params: { user: { name: name, email: email,
                                              password: '', password_confirmation: '' } }
    puts res
    assert_not flash.empty?
    assert_redirected_to @user

    # reloads user data from db
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

  test 'successful edit with friendly forwarding' do
    # try to access edit before logging in and check that we get redirected there after login
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    name = 'Foo Bar'
    email = 'foo@bar.com'
    patch user_path(@user), params: { user: { name: name, email: email,
                                              password: '', password_confirmation: '' } }

    assert_not flash.empty?
    assert_redirected_to @user
    # reloads user data from db
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

  test 'should redirect with friendly forwarding only once' do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    delete logout_path
    log_in_as(@user)
    assert_redirected_to @user
  end
end
