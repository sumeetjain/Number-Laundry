require 'number'

Headers = {"Content-Type" => "application/json", "X-Made-With" => "Joy"}

map "/" do
	whatcheer = lambda do |env|
	  return [301, {"Location" => "http://numberlaundry.whatcheer.com", "Content-Type" => "text/html"}, "http://numberlaundry.whatcheer.com"]
	end
	
	run whatcheer
end

map "/launder/" do
	laundry = lambda do |env|
	  query = env['PATH_INFO'].gsub!(/^./, '')
	  out = JSON.generate(ProcessNumber(query))
	  return [200, Headers, out]
	end
	
	run laundry
end

map "/launder/bulk/" do
	bulk = lambda do |env|
		request = Rack::Request.new(env)
		numbers = request.params["number"]
		
		if numbers
			arr = []
			numbers.each do |n|
				arr.push(JSON.generate(ProcessNumber(n)))
			end
						
			out = "[#{arr.join(',')}]"
		else
			out = '{"error":true, "message":"No Numbers Given"}'
		end
		
		return [200, Headers, out]  
	end
	
	run bulk
end