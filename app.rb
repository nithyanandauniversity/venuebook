class App < Padrino::Application

  set :public_folder, 'public'

  # register Padrino::Warden
  register Padrino::Rendering
  # register ScssInitializer
  # use ConnectionPoolManagement
  # register Padrino::Mailer
  # register Padrino::Helpers

  # set :default_strategies, [:jwt]
  # set :warden_default_scope, :user
  enable :sessions

  # set :warden_config do |config|
  #   config.scope_defaults(
  #     :user,
  #     :strategies => [:jwt],
  #     :config => {
  #       # :client_options => { :verify_ssl => OpenSSL::SSL::VERIFY_NONE }
  #       :secret => ENV['USER_JWT_SECRET']
  #     }
  #   )

  #   config.serialize_into_session do |user|
  #     # User.into_session(user)
  #     user.id
  #   end

  #   config.serialize_from_session do |id|
  #     # User.from_session(session)
  #     User.find(id: id)
  #   end
  # end

  # Add these routes below to the app file...
  get "/" do
    File.read(File.join('public', 'index.html'))
  end

  # get :about, :map => '/about_us' do
  #   render :haml, "%p This is a sample blog created to demonstrate how Padrino works!"
  # end
end
