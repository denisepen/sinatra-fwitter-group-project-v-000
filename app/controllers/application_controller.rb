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
  #  if logged_in?
   @tweet = Tweet.find(params[:id])
   @user = User.find(session[:user_id])
   @user.id = @tweet.user_id
   erb :"tweets/show"
 # else
 #   redirect '/login'
 # end
 end

 get '/tweets/:id/edit' do
   @user = User.find(session[:user_id])
   if @user
   @tweet = Tweet.find(params[:id])
   erb :"/tweets/edit"
 else
   redirect '/login'
 end
 end

get '/logout' do
  session.clear
  redirect '/login'
end

patch '/tweets/:id' do
  # binding.pry
   @tweet=Tweet.find(params[:id])
   @tweet.update(content: params[:tweet])
  # @tweet.content = params[:tweet]
  session[:tweet] = params[:tweet]
  @user = User.find(session[:id])
  @user.id = @tweet.user_id
  @tweet.save
  redirect "/tweets/#{@tweet.id}"
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

delete '/tweets/:id/delete' do
  @tweet = Tweet.find_by_id(params[:id])
  @tweet.delete
  redirect '/tweets'
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
