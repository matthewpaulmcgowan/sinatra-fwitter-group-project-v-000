require './config/environment'
require 'pry'
class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "password_security"
  end
  
  get '/' do 
    erb :index 
  end
  
  get '/signup' do 
    if logged_in?
      redirect "/tweets"
    else
      erb :"users/create_user"
    end
  end
  
  post '/signup' do 
    if params["username"] == "" || params["email"] == ""
      redirect "/signup"
    end
    
    @user = User.new(username: params["username"], email: params["email"], password: params["password"])
    if @user.save
      session[:id] = @user.id
      redirect "/tweets"
    else
      redirect "/signup"
    end
  end
  
  get '/login' do
    if session[:id].nil?
      erb :"users/login"
    else
      redirect "/tweets"
    end
  end
  
  post '/login' do
    @user = User.find_by(username: params["username"]) #cannot use current_user here because on the rspec for this, it does not register the session id, which the method uses rspec lines:81-92
    if @user && @user.authenticate(params["password"])
      session[:id] = @user.id 
      redirect '/tweets'
    else
      redirect "/login" 
    end
  end
  
  get '/logout' do
    if logged_in?
      session.clear
      redirect "/login"
    else
      redirect '/'
    end
  end
    
  get '/tweets' do
    @tweets = Tweet.all
    if logged_in?
      @user = current_user
      erb :"tweets/tweets"
    else 
      redirect "/login"
    end
  end
  
  get '/users/:slug' do
    @user = User.find_by_slug(params[:slug])
    erb :"users/user_homepage"
  end
  
  get '/tweets/new' do
    if logged_in?
      erb :"tweets/create_tweet"
    else
      redirect "/login"
    end
  end
  
  post "/tweets" do
    if params["content"] == "" 
      redirect "/tweets/new"
    end
    @user = current_user
    @tweet = Tweet.create(content: params["content"])
    @tweet.user_id = @user.id 
    @tweet.save
    erb :"users/user_homepage"
  end
  
  get '/tweets/:id' do 
    @tweet = current_tweet
    if logged_in?
      erb :"tweets/show_tweet"
    else
      redirect "/login"
    end
  end
  
  get '/tweets/:id/edit' do 
    if logged_in? 
      @tweet = current_tweet
        if @tweet.user_id == session[:id]
          erb :"tweets/edit_tweet"
        else
          redirect "/tweets"
        end
    else
      redirect "/login"
    end
  end
  
  patch '/tweets/:id' do
    @tweet = current_tweet
    if params["content"] == ""
      redirect "/tweets/#{@tweet.id}/edit"
    else
      @tweet.content = params["content"]
      @tweet.save
      redirect "tweets/#{@tweet.id}"
    end
  end
    
  delete '/tweets/:id/delete' do
    if logged_in?
      @tweet = current_tweet
      if current_user.id == @tweet.user_id 
        @tweet.delete
        redirect "/tweets"
      else
        redirect "/tweets"
      end
    else
      redirect '/login'
    end
  end
  
  helpers do
    def logged_in?
      !!session[:id]
    end

    def current_user
      User.find(session[:id])
    end
    
    def current_tweet
      Tweet.find(params[:id])
    end
  end

end