class User < ApplicationRecord
  has_secure_password
  has_many :tax_returns, dependent: :destroy
  has_many :exports, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }

  # Create test user if it doesn't exist (for development)
  def self.ensure_test_user
    User.find_or_create_by!(email: "test@local.test") do |user|
      user.password = "TestPassword123"
    end
  end
end
