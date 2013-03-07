#encoding: utf-8

require "sinatra/base"
require "slim"
require "digest/sha1"

module SessionTest
  class User
    def self.register(username, password)
      @users ||= {}
      return false if @users.keys.include?(username) or username.empty? or password.length < 5
      @users[username] = new(username, password)
      true
    end
    def self.all
      @users ||= {}
      @users.keys
    end
    def self.get(username)
      @users ||= {}
      return @users[username] if @users.keys.include? username
      nil
    end
    def initialize(username, password)
      @username = username
      @password = Digest::SHA1.hexdigest(password)
      @created_at = Time.now
    end
    attr_reader :username, :created_at
    def login(password)
      Digest::SHA1.hexdigest(password) == @password
    end
  end

  class SessionTest < Sinatra::Base
    # enable :sessions
    use Rack::Session::Pool, :expire_after => 86400
    set :views, File.expand_path("../views", __FILE__)

    get "/" do
      redirect to "/home"
    end

    get "/home" do
      @all_users = User.all.join(", ")
      if session[:user]
        @user = User.get(session[:user])
        slim :home, layout: true
      else
        slim :register, layout: true
      end
    end

    post "/login" do
      username = params["username"]
      password = params["password"]
      user = User.get(username)
      if user && user.login(password) then
        session[:user] = user.username
      end
      redirect to("/home")
    end

    post "/register" do
      username = params["username"]
      password = params["password"]
      if(password != params["password_retype"]) then
        redirect to("/home")
      elsif User.register(username, password) then
        session[:user] = User.get(username).username
      end
      redirect to("/home")
    end

    get "/logout" do
      session.destroy
      redirect to("/home")
    end
  end
end

SessionTest::SessionTest.run!