class TweetController < ApplicationController
    
  get '/tweets' do
    @tweets = Tweet.all
    if logged_in?
      @user = current_user
      erb :"tweets/tweets"
    else 
      redirect "/login"
    end
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
    @tweet = @user.tweets.create(content: params["content"])
    @tweet.save
    erb :"users/user_homepage"
  end
  
  get '/tweets/:id' do 
    @tweet = current_tweet
    @user = current_user
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
  
end