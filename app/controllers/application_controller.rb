require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    enable :sessions
    set :session_secret, "secret"
    set :public_folder, 'public'
    set :views, 'app/views'
  end

  get '/' do
    erb :index
  end

  helpers do
    def logged_in?
      !!session[:user_id]
    end
    def current_user
      User.find(session[:user_id])
    end
  end

  get '/login' do
    if logged_in?
      redirect '/tweets'
    else
      erb :login_in
    end
  end

  post '/login' do
    @user = User.find_by(:email => params[:email])

      if @user && @user.authenticate(params[:password])
          session[:user_id] = @user.id
          redirect '/tweets'
      else
          redirect '/login'
      end
  end

  get '/logout' do
    if logged_in?
      session.clear
      redirect "/login"
    else
      redirect "/"
    end
  end

  get '/tweets' do
    if !logged_in?
      redirect '/login'
    else
      @user = current_user
      erb :'/tweets/tweets'
  end
end

  get '/tweets/new' do
    if !logged_in?
      redirect '/login'
    else
      erb :'/tweets/create_tweet'
    end
  end

  post '/tweets' do
    if params[:content] == ""
      redirect '/tweets/new'
    else
      @user = User.find_by_id(session[:user_id])
      @tweet = Tweet.create(content: params[:content], user_id: @user.id)

      erb :"/tweets/show"
    end
  end

  get '/tweets/:id' do
    @tweet = Tweet.find(params[:id])

    erb :'/tweets/show'
  end

  get '/tweets/:id/edit' do
    if !logged_in?
      redirect to '/login'
    else
      @tweet = Tweet.find_by_id(params[:id])
      if @tweet.user.id == session[:user_id]
        erb :'/tweets/edit_tweet'
      else
        redirect '/tweets'
      end
    end
  end

  patch '/tweets/:id' do
    if params[:content].empty?
      redirect '/tweets/#{params[:id]}/edit'
    else
      @tweet = Tweet.find_by_id(params[:id])
      @tweet.content = params[:content]
      @tweet.save
      redirect to "/tweets/#{@tweet.id}"
    end
  end

  delete '/tweets/:id/delete' do
    if logged_in?
      @tweet = Tweet.find_by_id(params[:id])
      if @tweet.user_id == session[:user_id]
        @tweet.delete
        redirect to "/tweets"
      else
        redirect "/tweets"
      end
    else
      redirect '/login'
    end
  end


    get '/users/:slug' do
      @user = User.find_by_slug(:slug)
      erb :'/users/show'
    end

    get '/signup' do
      if logged_in?
        redirect "/tweets"
      else
        erb :sign_up
      end
    end

    post '/signup' do
      if params[:username] != "" && params[:email] != "" && params[:password] != ""
        @user = User.new(:username => params[:username])
        @user.email = params[:email]
        @user.password = params[:password]
        @user.save
        redirect '/tweets'
      else
        redirect '/signup'
      end
    end

end
