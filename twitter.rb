require 'sinatra'
require 'data_mapper'
DataMapper.setup(:default, 'sqlite:///'+Dir.pwd+'/project.db')
 
class User
    include DataMapper::Resource
 
    property :id, Serial
    property :firstn, String
    property :lastn, String
    property :email, String
    property :password, String
end

class Tweet
    include DataMapper::Resource
 
    property :id,         Serial    
    property :mess,       String   
    property :user_id,     Numeric
 	property :likes,       Numeric
    # attr_accessor :task, :done
    # def initialize task
    #   @task = task
    #   @done = false
    # end
end
 
class Like
	include DataMapper::Resource
 
    property :id,         Serial    
    property :user_id,       Numeric
    property :tweet_id,      Numeric
    property :stat,			 Boolean

 end

DataMapper.finalize
DataMapper.auto_upgrade!
 
enable :sessions

get '/' do
	if session[:user_id].nil?
		return redirect '/signin'
	end
	tweets=Tweet.all
	user=User.all(id: session[:user_id]).first
	erb :myHome,locals: {user_id: session[:user_id],tweets: tweets,user: user}
end

get '/signin' do
	erb :signinT
end

post '/signin' do
	email=params[:email]
	password=params[:password]
	user=User.all(email: email).first
	if user.nil?
		return redirect 'signup'
	elsif password==user.password
		session[:user_id]=user.id
		return redirect '/'
	else return redirect '/signin'
	end
end

get '/signup' do
	erb :signupT
end

post '/signup' do
	firstn=params[:firstn]
	lastn=params[:lastn]
	email=params[:email]
	password=params[:password]
	user=User.new
	user.firstn=firstn
	user.lastn=lastn
	user.email=email
	user.password=password
	user.id=session[:user_id]
	user.save
	session[:user_id]=user.id
	return redirect '/'
end

get '/signout' do
	session[:user_id]=nil
	return redirect '/'
end

post '/add' do
	mess=params[:mess]
	tweet=Tweet.new
	tweet.mess=mess
	tweet.user_id=session[:user_id]
	tweet.likes=0
	tweet.save
	return redirect '/'
end

post '/like' do
	tweet_id=params[:tweet_id].to_i
	tweet=Tweet.get(tweet_id)
	user_id=session[:user_id]
	liker=Like.all(tweet_id: tweet_id,user_id: user_id).first
	if liker.nil?
		likes=Like.new
		likes.tweet_id=tweet_id
		likes.user_id=session[:user_id]
		likes.stat=true
		tweet.likes=(tweet.likes.to_i+1).to_s
		likes.save
	elsif liker.stat
		 liker.stat=false
		 tweet.likes=(tweet.likes.to_i-1).to_s
		 liker.save
	else  liker.stat=true
		  tweet.likes=(tweet.likes.to_i+1).to_s
		  liker.save
	end
	tweet.save
	return redirect '/'
end