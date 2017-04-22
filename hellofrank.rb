require 'sinatra'
#require 'AfricasTalkingGateway'
require './AfricasTalkingGateway.rb'
require 'dotenv'
Dotenv.load #If more that one .env then Dotenv.load('one.env', 'two.env')

#The frank sinatra warmup
get '/frank-says' do 

	'put this in your pipe & smoke it'
	
end

#Send the SMS
get '/airtime-manenos' do
	#pull env variable
	username = ENV['API_LIVE_USERNAME']
	apikey = ENV['API_LIVE_KEY']
	#create instance of Gateway class
	gateway = AfricasTalkingGateway.new(username, apikey)
	#Send SMS
	result = gateway.sendMessage('+254708415904,+254701556803', 'Hello airtime, where are you?')
	puts result
end

post '/airtime-manenos' do
	#1. Get all the POST Parameters from AT
	#2. For the text - via short code - explode and take the last value
	#3. Do Mpesa-Checkout
	#4. On Success - send airtime
end 
