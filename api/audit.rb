class Audits < Grape::Middleware::Base

	def initialize(app, options = {})
		@app = app
	end

	def call(env)
		status, headers, response = @app.call(env)
		if env["api.endpoint"]
			log                       = {}
			log[:time]                = Time.now.utc
			log[:method]              = env['REQUEST_METHOD']
			log[:format]              = env['api.format']
			log[:url]                 = env['PATH_INFO']
			log[:status]              = status
			log[:ip]                  = env['REMOTE_ADDR']
			log[:query_params]        = env['rack.request.query_hash']
			log[:raw_request_body]    = env['api.request.input']
			log[:parsed_request_body] = env['api.request.body']

			response_body = ""
			# read the JSON string line by line
			response.each { |part| response_body += part }
			log[:response] = response_body

			puts "\n\n\n========================================="
			puts log.inspect
			puts "=========================================\n\n\n"
		end

		[status, headers, response]
	end

end
