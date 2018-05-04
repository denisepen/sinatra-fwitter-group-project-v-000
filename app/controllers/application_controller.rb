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
   if logged_in?
     redirect '/tweets'
   else
  erb :"/users/signup"
end
end

get '/login' do
  if logged_in?
    redirect '/tweets'
  else
  erb :"/users/login"
end
end

get '/tweets' do
  if logged_in?
  @user = User.find(session[:user_id])
 session[:user_id] = @user.id
  erb :"/tweets/tweets"
else
  redirect '/users/login'
end
end

 get '/tweets/new' do
  #  raise session.inspect
  # @user = User.find(session[:user_id])
   if   logged_in?
     erb :"/tweets/new"
   else
     redirect '/login'
   end
 end

 get '/tweets/:id' do

    @tweet = Tweet.find(params[:id])
    # if logged_in?
   if session[:user_id] == @tweet.user_id

     @user = User.find(session[:user_id])
   erb :"tweets/show"
 elsif logged_in? && session[:user_id] != @tweet.user_id
   @user = User.find(session[:user_id])
   erb :"tweets/show"

 else

   redirect '/login'
 end
 end

 get '/tweets/:id/edit' do
   @user = User.find(session[:user_id])
   @tweet = Tweet.find(params[:id])
   if @user.id == @tweet.user_id

   erb :"/tweets/edit"
 else
   redirect '/tweets'
 end
 end

 get "/users/:slug" do
  # binding.pry
   @user = User.find_by_slug(params[:slug])
   if @user.id == session[:user_id]
     erb :'/users/show'
   else
     redirect '/tweets'
   end
 end

get '/logout' do
    session.clear
  redirect '/login'
 end

patch '/tweets/:id' do
  # binding.pry
  if logged_in?
   @tweet=Tweet.find(params[:id])
     if !params[:content].empty?
       @tweet.update(content: params[:content])
      # @tweet.content = params[:tweet]
      session[:tweet] = params[:content]
      @user = User.find(session[:user_id])
      @user.id = @tweet.user_id
      @tweet.save
      redirect "/tweets/#{@tweet.id}"
    else
      redirect "/tweets/#{@tweet.id}/edit"
    end
else
  redirect '/login'
end
end

post '/show' do
  @user=User.find(session[:user_id])
  @tweet = Tweet.new(content: params[:content])
  if params[:content].empty?
    redirect '/tweets/new'
  else
  @tweet.save
  session[:tweet] = params[:content]

  @user.tweets << @tweet

  erb :"/users/show"
end
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
    if user && user.authenticate(params[:password]) #|| logged_in?
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
  
    @tweet =Tweet.find_by_id(params[:id])
   if !logged_in? || @tweet.user_id != session[:id]

    redirect '/tweets'
else
    @tweet.delete
    redirect '/tweets'

end
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
