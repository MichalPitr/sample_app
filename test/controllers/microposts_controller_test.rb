require "test_helper"

class MicropostsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @micropost = microposts(:orange)
  end

  test 'should redirect create when not logged in' do
    assert_no_difference 'Micropost.count' do
      # notice pular 'microposts'
      post microposts_path, params: { micropost: { content: 'Lorem ipsum' } }
    end
    assert_redirected_to login_url
  end

  test 'should redirect destroy when not logged in' do
    assert_no_difference 'Micropost.count' do
      # notice singular 'micropost'
      delete micropost_path(@micropost)
    end
    assert_response :see_other
    assert_redirected_to login_url
  end

  test 'only micropost owner should be able to delete their posts' do
    not_owner = users(:michael)
    log_in_as not_owner
    archers_micropost = microposts(:ants)
    assert_no_difference 'Micropost.count' do
      delete micropost_path(archers_micropost)
    end
    assert_redirected_to root_url
    assert_response :see_other
  end
end
