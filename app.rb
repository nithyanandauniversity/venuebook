class App < Padrino::Application
  set :public_folder, '/public'
  register Padrino::Warden
  register Padrino::Rendering
  # register ScssInitializer
  # use ConnectionPoolManagement
  # register Padrino::Mailer
  # register Padrino::Helpers
  set :public_folder, 'public'

  set :default_strategies, [:jwt]
  set :warden_default_scope, :default
  enable :sessions

  set :warden_config do |config|
    config.scope_defaults(
      :default,
      :strategies => [:jwt],
      :config => {
        # :client_options => { :verify_ssl => OpenSSL::SSL::VERIFY_NONE }
        :secret => ENV['IDENTITY_JWT_SECRET']
      }
    )

    config.serialize_into_session { |user| User.into_session(user) }
    config.serialize_from_session { |session| User.from_session(session) }
  end

  # Add these routes below to the app file...
  get "/" do
    File.read(File.join('public', 'index.html'))
  end

  get :about, :map => '/about_us' do
    render :haml, "%p This is a sample blog created to demonstrate how Padrino works!"
  end
end
