instaStalker
============

**instaStalker** is a tool that helps you collect geolocation data for an instagram user and pinpoint a possible location. Some users like to take photos with their phone camera and then when they get home to their precious WiFi upload the pictures to Instagram. If you don't add a venue to your photo (which is optional), Instagram will take your current location and put it in the Photo Map. So, if you upload many pictures that way, well someone may take a guess on where you kinda live :) The app is also live @ http://instastalker.herokuapp.com/

Requirements
------------
You'll need ruby installed on your system (I'm using v1.9.2) along with some gems (sinatra, instagram). Run

    bundle install

in order to install the gems and then

    ruby instaStalker.rb

and the app should start running on localhost:4567
