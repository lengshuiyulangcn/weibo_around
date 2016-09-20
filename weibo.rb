require 'sinatra'
require 'sinatra/reloader'
require 'weibo_2'
require "json"

WeiboOAuth2::Config.api_key = ENV['KEY']
WeiboOAuth2::Config.api_secret = ENV['SECRET']
WeiboOAuth2::Config.redirect_uri = ENV['REDIR_URI']

ACCESS_TOKEN = ""
EXPIRES_AT=""
get '/connect' do
  client = WeiboOAuth2::Client.new
  redirect client.authorize_url
end


get '/callback' do
  client = WeiboOAuth2::Client.new
  access_token = client.auth_code.get_token(params[:code].to_s)
  ACCESS_TOKEN = access_token.token
  EXPIRES_AT= access_token.expires_at
  p "*" * 80 + "callback"
  redirect '/nearby'
end

get '/nearby' do
  client = WeiboOAuth2::Client.new
  client.get_token_from_hash({:access_token => ACCESS_TOKEN, :expires_at => EXPIRES_AT})
  puts EXPIRES_AT
  unless Time.now.to_i > EXPIRES_AT.to_i
    place=client.place
    lat=params[:lat] || 35.6492072
    log=params[:lng] || 139.6895226
    opt={}
    opt[:count]= params[:count] || 50
    if params[:page]
        opt[:page]=params[:page].to_i
    end
    place.nearby_users(lat,log,opt).to_json
  else
    redirect '/connect'
  end
end

