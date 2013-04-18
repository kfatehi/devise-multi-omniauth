class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:github, :weibo, :google_oauth2]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body
  #
  has_many :identities

  def self.find_oauth(provider, auth, signed_in_resource=nil)
    identity = Identity.where(:provider => auth.provider, :uid => auth.uid).first
    unless identity && identity.user
      identity = Identity.where(
        provider:auth.provider,
        uid:auth.uid
      ).first_or_create

      user = User.new(
        email: auth.info.email,
        password: Devise.friendly_token[0,20]
      )

      user.identities << identity
      identity.user = user
      user.save
    end

    identity.user
  end
end
