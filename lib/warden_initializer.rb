require 'warden/jwt'
require 'openssl/ssl'

Warden::Strategies.add(:jwt, Warden::JWT::Strategy) do

  # over-ride success! to turn the JWT-response into a user that our app
  # can understand, then call super
  def success!(user, message=nil)
    user = User.find(:email => user.email)# do |u|
    #   u.email          = user.email
    #   u.name           = user.n
    #   u.plain_password = 'oauthuser'
    #   u.role           = user.r || 'default'
    #   u.permissions    = user.permissions || []
    # end

    puts user.inspect

    super(user, message)
  end
end

