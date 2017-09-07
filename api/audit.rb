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
			log[:namespace]           = env['namespace']
			log[:raw_request_body]    = env['api.request.input']
			log[:parsed_request_body] = env['api.request.body']

			response_body = ""

			current_user = Audits.current_user(env['HTTP_TOKEN'])
			log[:current_user] = current_user ? current_user[0] : nil

			# read the JSON string line by line
			response.each { |part| response_body += part }
			log[:response] = response_body

			puts "\n\n\n========================================="
			puts log.inspect
			puts "=========================================\n\n\n"

			Audits.log_request(log)
		end

		[status, headers, response]
	end


	private

	def self.current_user(token)
		if token
			begin
				decoded_token = JWT.decode token, SECRET, true, { :algorithm => 'HS256' }
				if decoded_token
					return decoded_token
				else
					return false
				end
			rescue Exception => e
				return false
			end
		else
			return false
		end
	end


	def self.log_request(log)
		begin
			#
		rescue Exception => e
			#
		end
	end

end
