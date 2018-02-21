class Audits < Grape::Middleware::Base

	def initialize(app, options = {})
		@app = app
	end

	def call(env)
		status, headers, response = @app.call(env)
		if env["api.endpoint"]
			log                       = {}
			log[:request_time]        = Time.now.utc
			log[:method]              = env['REQUEST_METHOD']
			# log[:format]              = env['api.format']
			log[:url]                 = env['PATH_INFO']
			log[:status]              = status
			log[:ip_address]          = env['REMOTE_ADDR']
			log[:query_params]        = env['rack.request.query_hash'].to_s
			log[:namespace]           = env["grape.routing_args"][:route_info].options[:namespace]
			log[:raw_request_body]    = env['api.request.input']
			# log[:parsed_request_body] = env['api.request.body']

			response_body = ""
			# read the JSON string line by line
			response.each { |part| response_body += part }
			log[:response] = response_body

			current_user       = Audits.current_user(env['HTTP_TOKEN'])
			log[:current_user] = current_user ? current_user[0] : nil
			log[:category]     = Audits.get_category(log[:namespace])
			log[:sub_category] = Audits.get_sub_category(log[:url])
			log[:resource]     = Audits.get_resource(log[:namespace], log[:method], log[:url], response_body)

			# puts "\n\n\n========================================="
			# puts log.inspect
			# puts "=========================================\n\n\n"

			unless log[:namespace] == "/sessions" && log[:parsed_request_body].nil?
				Audits.log_request(log)
			end

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

	def self.get_category(namespace)
		return !namespace.empty? ? namespace.gsub("/","").split("_").map {|a| a.capitalize}.join(" ") : nil
	end

	def self.get_sub_category(url)
		arr = url.split('/')
		if arr.length > 4
			main_cat = Audits.get_category("/#{arr[2]}")
			sub_cat  = Audits.get_category("/#{arr[4]}")
			return "#{main_cat} #{sub_cat}"
		else
			return nil
		end
	end

	def self.get_resource(namespace, method, url, response)
		resource = {}
		resource[:resource_name] = Audits.get_resource_name(namespace)
		resource[:resource_id]   = resource[:resource_name] ? Audits.get_resource_id(method, url, response) : nil
		return resource.to_json()
	end

	def self.get_resource_name(namespace)
		case namespace
		when "/sessions"
			return nil
		when "/participants"
			return "Participant"
		when "/centers"
			return "Center"
		when "/events"
			return "Event"
		when "/settings"
			return "Setting"
		when "/programs"
			return "Program"
		when "/event_attendances"
			return "EventAttendance"
		when "/users"
			return "User"
		when "/venues"
			return "Venue"
		else
			return ""
		end
	end

	def self.get_resource_id(method, url, response)
		resource_id = nil

		case method
		when "GET"
			if url.split('/').length > 3
				resource_id = url.split('/')[3]
			end
			return resource_id
		when "POST"
			if url.split('/').length > 3
				resource_id = url.split('/')[3]
			end
			return resource_id
		when "PUT"
			resource_id = url.split('/')[3]
			return resource_id
		when "DELETE"
			resource_id = url.split('/')[3]
			return resource_id
		else
			return resource_id
		end
	end

	def self.log_request(params)
		log = Logger.new(STDOUT)
		begin
			# Post data to the AuditLogs API
			response = RestClient.post AUDITBOOK_URL, audit_log: params
			log.info response.inspect

		rescue Exception => e
			log.error(e.inspect)
		end
	end

end
