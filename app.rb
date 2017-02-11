# module SampleBlogUpdated
  class App < Padrino::Application
  set :public_folder, '/public'
    # register ScssInitializer
    # use ConnectionPoolManagement
    # register Padrino::Mailer
    # register Padrino::Helpers
    set :public_folder, 'public'
    enable :sessions

    # Add these routes below to the app file...
    get "/" do
      File.read(File.join('public', 'index.html'))
    end

    get :about, :map => '/about_us' do
      render :haml, "%p This is a sample blog created to demonstrate how Padrino works!"
    end
  end
# end