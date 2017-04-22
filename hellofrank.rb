require 'sinatra'
require 'AfricasTalkingGateway'
require 'dotenv'
Dotenv.load #If more that one .env then Dotenv.load('one.env', 'two.env')

#The frank sinatra warmup
get '/frank-says' do 

	'put this in your pipe & smoke it'
	
end

