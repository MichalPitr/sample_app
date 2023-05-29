require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                    password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = ""
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = ""
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = 'a'*51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = 'a'*244 + '@example.com'
    assert_not @user.valid?
  end

  test "email validation should accept valid emals" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                        first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                          foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email address should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email address should be saved as lowercase" do
    mixed_case_email = "FoO@eXamPlE.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present" do
    @user.password = @user.password_confirmation = " " * 6
    @user.save
    assert_not @user.valid?
  end

  test "password should have minimum length of 6" do
    @user.password = @user.password_confirmation = "a" * 5
    @user.save
    assert_not @user.valid?
  end

  test 'associated microposts should be destroyed' do
    @user.save
    @user.microposts.create!(content: 'Lorem ipsum')
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test 'should follow and unfollow users' do
    michael = users(:michael)
    archer = users(:archer)
    assert archer.valid?
    assert michael.valid?
    assert_not michael.following?(archer)
    michael.follow(archer)
    assert michael.following?(archer)
    assert archer.followers.include?(michael)
    michael.unfollow(archer)
    assert_not michael.following?(archer)

    # User cannot follow themselves!
    michael.follow(michael)
    assert_not michael.following?(michael)
  end

  test 'feed should have the right posts' do
    michael = users(:michael)
    archer = users(:archer)
    lana = users(:lana)

    # michael's feed should include all lana's posts
    lana.microposts.each do |post_following|
      assert michael.feed.include?(post_following)
    end

    # michael's feed should include his own posts
    michael.microposts.each do |own_post|
      assert michael.feed.include?(own_post)
    end
    # every item should only occur once
    assert_equal michael.feed.distinct, michael.feed

    # michael's feed should not include posts from unfollowed users
    archer.microposts.each do |unfollowed_post|
      assert_not michael.feed.include?(unfollowed_post)
    end
  end
end
