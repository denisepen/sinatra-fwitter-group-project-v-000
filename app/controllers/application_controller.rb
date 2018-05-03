require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "secret"
  end

get '/' do
erb :homepage
  #homepage
end

get '/signup' do
  erb :signup
  #signup page
end

get '/login' do
  erb :login
end

get '/tweets' do
  @user = User.find(session[:user_id])
  # binding.pry
 session[:user_id] = @user.id
  erb :tweets
end

 get '/tweets/new' do
  #  raise session.inspect
   if session[:username].empty?
     redirect '/login'
   else
     erb :new
   end
 end

get '/logout' do
  session.clear
  redirect '/login'
end

post '/show' do
  @user=User.find(params[:user_id])
  erb :show
end
post '/signup' do

    if params[:username].empty? || params[:email].empty? || params[:password].empty?
         redirect "/signup"
     else
       
      #  binding.pry
       session[:user_id] = @user.id
       session[:email] = params[:email]
       session[:username] = params[:username]
       @user = User.create(:username => params[:username], :email => params[:email], :password => params[:password])
       @user.save
       redirect '/tweets'
    end
end


post "/login" do
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
          session[:user_id] = user.id
          session[:email] = params[:email]
          session[:username] = params[:username]
        redirect "/tweets"
    else
        redirect "/login"
    end
end

post '/tweets' do

end

helpers do
		def logged_in?
			!!session[:user_id]
		end

		def current_user
			User.find(session[:user_id])
		end
	end
end
