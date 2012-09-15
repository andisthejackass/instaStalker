require "instagram"
require "sinatra"

enable :sessions

CALLBACK_URL = "http://localhost:4567/oauth/callback"

Instagram.configure do |conf|
  conf.client_id = "93d1fb42db9345a1bae22664f93de3ec"
  conf.client_secret = "26ea1d47340f4502830720b73ac4d05a"
end

get "/" do
  '<link rel="stylesheet" type="text/css" href="../css/style.css" />
  <center><h1>In order to use instaStalker, you need to authorize it first
  <div id="connect_container">
    <a href="/oauth/connect" id="connect"><span class="wootspan"></span></a>
  </div>' + links
end

get "/oauth/connect" do
  redirect Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
end

get "/oauth/callback" do
  response = Instagram.get_access_token(params[:code], :redirect_uri => CALLBACK_URL)
  session[:access_token] = response.access_token
  redirect "/search"
end

get "/search" do
  '<center><h1>Enter a username you want to search: </br>
  <form action="/form" method="post">
  <input type="text" name="victim">
  <input type="submit" value="Stalk!">
  </form><h4>E.g. <b>dens</b> or <b>jack</b> :)</h4></br>' + links
end
post '/form' do
  redirect "/stalker/" + params[:victim]
end
get "/stalker/:victim" do
  victim = params[:victim]
  victim_ig = Instagram.user_search(victim,options={:access_token => session[:access_token]}).first
  client = Instagram.client(:access_token => session[:access_token])
  user = victim_ig
  count = 0
  array = []
  a = []
  if user != nil
    html = "<!DOCTYPE html><html><head><center><h1>instaStalker for user <b>#{user.username}</b> | ID: #{user.id}</h1></br><img src='#{user.profile_picture}' ></img></br>  <form action='/form' method='post'>
  <input type='text' name='victim'>
  <input type='submit' value='Stalk!'>
  </form></br>"
    for media_item in client.user_recent_media(user.id, options={:count => "-1"})
      if media_item.location != nil
        count = count + 1
        location = media_item.location.latitude.to_s[0..5] + media_item.location.longitude.to_s[0..5]
        array = array + [location]
      end
    end
    freq = array.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
    top_array = array.sort_by { |v| freq[v] }.last
    times = freq.first[1] unless freq.first.nil?
    if top_array != nil
      victim_location = top_array.scan(/.{6}|.+/).join(",")
      html << "Out of <b>#{count}</b> geotagged photos <b>#{times}</b> were taken @ <b>#{victim_location} "
      html << '<link rel="stylesheet" type="text/css" href="../css/style.css" />'
      html << '<script src="https://maps.googleapis.com/maps/api/js?sensor=false"></script>
        <script>
          function initialize() {
            var myLatlng = new google.maps.LatLng(' + victim_location + ');
            var mapOptions = {
              zoom: 13,
              center: myLatlng,
              mapTypeId: google.maps.MapTypeId.ROADMAP
            }
            var map = new google.maps.Map(document.getElementById(\'map_canvas\'), mapOptions);

            var marker = new google.maps.Marker({
                position: myLatlng,
                map: map,
                title: \'Hello World!\'
            });
          }
        </script></head>
          <body onload="initialize()">
        <div id="map_canvas"></div>
      </body></html>'
    else
      html << "Sorry, #{user.username} hasn't geotagged any photos :/</br>"
    end
   end
  if victim_ig.nil?
    '<center><h1>Sorry, user not found :/</br>' + links
  else
    html + links
  end
end

get "/about" do
  '<center><h2>instaStalker was made in order to raise awareness in the geolocation feature offered by Instagram.</br>
  While geolocation is great and fun, some privacy issues may rise without the users\' knowledge. For example, some users (some meaning me and not sure if anyone else...) like to take photos with their phone camera and then when they get home to their precious WiFi upload the pictures to Instagram. If you don\'t add a venue to your photo (which is optional), Instagram will take your current location and put it in the Photo Map. So, if you upload many pictures that way, well someone may take a guess on where you kinda live :) </h2></br><a href="javascript: history.go(-1)">Back to instaStalker</a>'
end

def links
  '<a href="/about">About</a>'
end
