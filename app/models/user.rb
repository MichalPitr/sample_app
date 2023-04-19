class User < ApplicationRecord
  attr_accessor :remember_token

  before_save { self.email = email.downcase }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true

  has_secure_password
  # Allow empty passwords for updates, has_secure_password already does a presence check for signup.
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost:)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token

    # updates the instance symbol remember digest with the hash of self.remember_token
    # we need to use update_attribute because this way we bypass validations (i.e. missing password!)
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  def session_token
    # prevents section hijacking - chapter 9.3 exercise 2
    remember_digest || remember
  end

  def authenticated?(remember_token)
    return false if remember_digest.nil?

    remember_digest.nil? ? false : BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end
end
