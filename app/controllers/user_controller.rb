class UserController < ApplicationController
   
  get '/signup' do 
    if logged_in?
      redirect "/tweets"
    else
      erb :"users/create_user"
    end
  end
  
  post '/signup' do 
    @user = User.new(params)
    if @user.valid?
      @user.save
      session[:id] = @user.id
      redirect "/tweets"
    else
      redirect "/signup"
    end
  end
  
  get '/login' do
    if !logged_in?
      erb :"users/login"
    else
      redirect "/tweets"
    end
  end
  
  post '/login' do
    @user = User.find_by(username: params["username"]) 
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
  
  get '/users/:slug' do
    @user = User.find_by_slug(params[:slug])
    erb :"users/user_homepage"
  end
  
end