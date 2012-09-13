require "instagram"
require "sinatra"

enable :sessions

CALLBACK_URL = "http://localhost:4567/oauth/callback"

Instagram.configure do |conf|
  conf.client_id = "93d1fb42db9345a1bae22664f93de3ec"
  conf.client_secret = "26ea1d47340f4502830720b73ac4d05a"
end

get "/" do
  '<a href="/oauth/connect">Connect with Instagram</a>'
end

get "/oauth/connect" do
  redirect Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
end

get "/oauth/callback" do
  response = Instagram.get_access_token(params[:code], :redirect_uri => CALLBACK_URL)
  session[:access_token] = response.access_token
  redirect "/stalker"
end

get "/stalker" do
  client = Instagram.client(:access_token => session[:access_token])
  user = client.user
  count = 1

  html = "<h1>#{user.username}'s recent photos | #{user.id}</h1>"
  for media_item in client.user_recent_media(options={:count => "-1"})
    html << "<h3>#{count}</h3>. Long:#{media_item.location.longitude unless media_item.location.nil?}"
    count = count + 1
  end
  html
end
