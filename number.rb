require 'rubygems'
require 'json'

data = File.open('data.json', 'r')
json = data.readlines.to_s
PhoneData = JSON.parse(json)['data']

def ProcessNumber(number)
	@sink = {}
	
	@clean = number.gsub(/[^0-9\+]/, '')
	if @clean[0].chr != "+" and @clean.length == 10
		@clean = "1#{@clean}"
	end
	@clean = "+#{@clean}"
	
	@sink[:source] = number;
	@sink[:error] = false;

	if @clean.length < 10
		@sink[:error] = true
		@sink[:message] = 'Not A Valid Number'
	else
		@sink[:clean] = @clean;
		@sink[:twilio] = nil
		@sink[:country] = nil

		@found = false
	
		PhoneData.each do |d|
			data = d[1]
		
			if @clean.index(data['prefix']) == 1
				@sink[:twilio] = {:rate => data['twilio_rate'], :prefix => data['prefix']}
				@sink[:country] = {:name => data['country'], :code => data['country_code']}

				# Fix Canadian numbers (bad Twilio data) :-\
				if @sink[:country][:code] == 'US'
					canadian_area_codes = [403, 587, 780, 587, 604, 778, 250, 204, 506, 709, 867, 902, 905, 289, 519, 226, 705, 249, 613, 343, 897, 416, 647, 902, 418, 581, 450, 579, 514, 438, 819, 306, 867]
				
					if canadian_area_codes.include? @clean[2, 3].to_i
						@sink[:country][:name] = 'Canada'
						@sink[:country][:code] = 'CA'
					end
				end
			
				@sink[:country][:flag] = "http://numberlaundry-icons.s3.amazonaws.com/#{@sink[:country][:code].downcase}.png"
			
				@found = true
				break
			end
		end
	end
	
	@sink
end