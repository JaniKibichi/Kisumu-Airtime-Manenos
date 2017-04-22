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
	#pull env variable
	username = ENV['API_LIVE_USERNAME']
	apikey = ENV['API_LIVE_KEY']

	#1. Get all the POST Parameters from AT
		#a. short code (http://docs.africastalking.com/sms/callback)
		@from = params[:from]
		@to = params[:to]
		@date = params[:date]
		@text = params[:text]
		@id = params[:id]
		@linkId = params[:linkId]

		#b. Mpesa (http://docs.africastalking.com/payments/notification)
		@category = params[:category]
		@providerRefId = params[:providerRefId]
		@productName = params[:productName]
		@sourceType = params[:sourceType]	
		@source = params[:source]
		@destination = params[:destination]
		@value = params[:value]
		@status = params[:status]
		@description = params[:description]
		@requestMetadata = params[:requestMetadata]
		@providerMetadata = params[:providerMetadata]
		@transactionDate = params[:transactionDate]				
	
		#c. airtime (http://docs.africastalking.com/airtime/callback)
		@status = params[:status]
		@requestId = params[:requestId]

	#2. For the text - via short code - explode and take the last value
		#2.a. explode text & Do Mpesa-Checkout
		if !@text.nil?	
			@airtimeRequest = @text.split(' ').last.to_i
			#2.a.1. Mpesa Checkout
			sendCheckout(@airtimeRequest.to_i, @from)
		end		
	#3. On Success - send airtime
		#3.a. if the providerRefId exits (on success) and category is MobileCheckout
		if !@providerRefId.nil?	&& @category == "MobileCheckout"
			@airtimeValue = @value.split(' ').last.to_i
			#3.a.1 send airtime
			sendAirtime(@airtimeValue.to_i, @source)			
		end

	#Put all the params to the console
	if params[:linkId]
		puts params + "Sent request for airtime++++++++++++++++++++++++++++"
	end

	if params[:category]
		puts params + "Just paid for airtime++++++++++++++++++++++++++++"
	end

	if params[:requestId]
		puts params + "Just received airtime++++++++++++++++++++++++++++"
	end	
	
end 


#methods
def sendCheckout(amount,from)
	#pull env variable
	username = ENV['API_LIVE_USERNAME']
	apikey = ENV['API_LIVE_KEY']

	#define params
	productName  = "Nerd Payments"
	currencyCode = "KES"
	metadata     = {"product"=>'airtime',"client"=>from}
	gateway = AfricasTalkingGateway.new(username, apikey)
	begin
	    # Initiate the checkout. If successful, you will get back a transactionId
	    transactionId = gateway.initiateMobilePaymentCheckout(productName, from,  currencyCode, amount, metadata)
	    puts transactionId
	    
	rescue Exception => ex
	    puts "Encountered an error with Mpesa Checkout: " + ex.message
	end
end

#methods
def sendAirtime(amount, source)
	#pull env variable
	username = ENV['API_LIVE_USERNAME']
	apikey = ENV['API_LIVE_KEY']
		
	#define params
	recipients = Array.new
	recipients[0] = {"phoneNumber" => source, "amount" => amount}
	gateway = AfricasTalkingGateway.new(username, apikey)
	begin
		#send Airtime
		results = gateway.sendAirtime(recipients)
		puts results
	rescue AfricasTalkingGatewayException => ex
	  puts 'Encountered an error with airtime sending: ' + ex.message
	end
end