#encoding: utf-8

require "sinatra/base"
require "slim"

module SessionTest
  class SessionTest < Sinatra::Base
    # enable :sessions
    use Rack::Session::Pool, :expire_after => 86400
    set :views, File.expand_path("../views", __FILE__)

    get "/" do
      session[:value] ||= rand(1000)
      @session_id = session.inspect
      slim :session, layout: true
    end
  end
end

SessionTest::SessionTest.run!