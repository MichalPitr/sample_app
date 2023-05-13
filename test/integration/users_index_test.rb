require "test_helper"

class UsersIndex < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:michael)
    @non_admin = users(:archer)
  end
end

class UsersIndexAdmin < UsersIndex
  def setup
    super
    log_in_as(@admin)
    get users_path
  end
end

class UsersIndexAdminTest < UsersIndexAdmin
  test 'should render the index page' do
    assert_template 'users/index'
  end

  test 'should paginate users' do
    assert_select 'div.pagination', count: 2
  end

  test 'should have delete links' do
    first_users_page = User.where(activated: true).paginate(page: 1)
    first_users_page.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
    assert_response :see_other
    assert_redirected_to users_url
  end

  test 'index should only display activated users' do
    # Deactivate the first user to ensure the inactive user is on the first page!
    User.paginate(page: 1).first.toggle!(:activated)

    assigns(:users).each do |user|
      assert user.activated?
    end
  end
end

class UsersNonAdminIndexTest < UsersIndex
  test 'index as non_admin has no delete links' do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
end
