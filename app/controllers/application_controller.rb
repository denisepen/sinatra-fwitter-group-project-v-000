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
  # if !current_user
  erb :"/users/signup"

end

get '/login' do
  erb :"/users/login"
end

get '/tweets' do
  @user = User.find(session[:user_id])
  # binding.pry
  if logged_in?

 session[:user_id] = @user.id
  erb :"tweets/tweets"
end
end

 get '/tweets/new' do
  #  raise session.inspect
   if  !logged_in?
     redirect '/login'
   else
     erb :"/tweets/new"
   end
 end

 get '/tweets/:id' do
   @tweet = tweet.find(params[:id])
   erb :"tweets/show"
 end

 get '/tweets/:id/edit' do
   @tweet = tweet.find(params[:id])
   erb :"/tweets/edit"
 end

get '/logout' do
  session.clear
  redirect '/login'
end

post '/show' do
  @user=User.find(session[:user_id])
  @tweet = Tweet.new(content: params[:tweet])
  @tweet.save
  session[:tweet] = params[:tweet]

  @user.tweets << @tweet

  erb :"/users/show"
end

post '/signup' do

    if params[:username].empty? || params[:email].empty? || params[:password].empty?  #&& !logged_in?
         redirect "/signup"
     else
       @user = User.create(:username => params[:username], :email => params[:email], :password => params[:password])
       @user.save
       if  logged_in? || @user.save
       session[:user_id] = @user.id
       session[:email] = @user.email
       session[:username] = @user.username

       redirect '/tweets'
     end
    end
end


post "/login" do
     user = User.find_by(username: params[:username])
    # if user
    if user && user.authenticate(params[:password])
      # User.find_by(username: params[:username])
          session[:user_id] = user.id
          session[:email] = user.email
          session[:username] = user.username
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
