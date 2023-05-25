require "test_helper"

class MicropostsInterface < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    log_in_as(@user)
  end
end

class MicropostsInterfaceTest < MicropostsInterface
  test 'should paginate microposts' do
    get root_path
    assert_select 'div.pagination', count: 1
  end

  test 'should show errors but not create micropost on invalid submission' do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: '' } }
    end
    assert_select 'div#error_explanation'
    assert_select 'a[href=?]', '/?page=2' # correct pagination link
  end

  test 'should create micropost on valid submission' do
    content = 'This is a valid post!'
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content } }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
  end

  test 'should have micropost delete links on own profile' do
    get user_path(@user)
    assert_select 'a', text: 'delete'
  end

  test 'should be able to delete own microposts' do
    first_micropost = @user.microposts.first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
  end

  test 'should not see delete links on other users microposts' do
    other_user = users(:archer)
    get user_path(other_user)
    assert_select 'a', { text: 'delete', count: 0 }
  end

  test 'should not be able to delete other users posts' do
    other_users_post = microposts(:ants)
    assert_no_difference 'Micropost.count' do
      delete micropost_path(other_users_post)
    end
  end
end

class MicropostSidebarTest < MicropostsInterface

  test 'should display the correct number of microposts' do
    get root_path
    assert_match "#{ @user.microposts.count} microposts", response.body
  end

  test 'should use proper pluralization for 0 microposts' do
    log_in_as(users(:malory))
    get root_path
    assert_match '0 microposts', response.body
  end

  test 'should use proper pluralization for 1 micropost' do
    log_in_as(users(:lana))
    get root_path
    assert_match '1 micropost', response.body
  end
end

class ImageUploadtest <MicropostsInterface

  test 'form should have image upload field' do
    get root_path
    assert_select 'input[type=file]', count: 1
  end

  test 'should be able to attach an image' do
    content = 'This is a post with an image'
    image = fixture_file_upload('kitten.jpg', 'image/jpg')
    post microposts_path, params: { micropost: { content: content, image: image } }
    assert @user.microposts.first.image.attached?
  end
end
