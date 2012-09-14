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
  redirect "/search"
end

get "/search" do
  '<form action="/form" method="post">
  <input type="text" name="victim">
  <input type="submit">
  </form>'
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
    html = "<!DOCTYPE html><html><head><h1>instaStalker for user <b>#{user.username}</b> | ID: #{user.id}</h1></br><a href='../search'>New Search</a></br>"
    for media_item in client.user_recent_media(user.id, options={:count => "-1"})
      if media_item.location != nil
        count = count + 1
        location = media_item.location.latitude.to_s[0..5] + media_item.location.longitude.to_s[0..5]
        array = array + [location]
      end
    end
    freq = array.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
    victim_location = array.sort_by { |v| freq[v] }.last.scan(/.{6}|.+/).join(",")
    html << "Out of #{count} locations, the victim's location is probaly <b>#{victim_location}</b>"
    html << '<link rel="stylesheet" type="text/css" href="../css/style.css" />'
    html << '</style><script src="https://maps.googleapis.com/maps/api/js?sensor=false"></script>
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
   end
  if victim_ig.nil?
    '<h1>Sorry, user not found :/'
  else
    html
  end
end
