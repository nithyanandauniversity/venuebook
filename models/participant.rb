require 'rest_client'

class Participant < Sequel::Model
	self.plugin :timestamps
	one_to_many :event_attendances

	def self.search(params)
		response = RestClient.get PARBOOK_URL, {params: params}
		JSON.parse(response.body)
	end

	def self.download(params)
		response = RestClient.get PARBOOK_URL, {params: params}
		results  = JSON.parse(response.body)

		csv   = []
		smkts = ["None", "Volunteer", "Thanedar", "Kotari", "Mahant", "Sri Mahant"]
		# CSV.open("participants_#{params[:center_code]}.csv", "w") do |csv|

		# end

		row = ["First name", "Last name", "Email Address", "Contact number"]

		row << "Address" if [true, 'true'].include?(params[:download][:with_address])
		row << "IA Graduate" if [true, 'true'].include?(params[:download][:ia_graduate])
		row << "SMKT" if [true, 'true'].include?(params[:download][:smkt])
		row << "Gender" if [true, 'true'].include?(params[:download][:gender])
		row << "Enrichers" if [true, 'true'].include?(params[:download][:enrichers])
		row << "Created by" if [true, 'true'].include?(params[:download][:created_by])
		row << "Created at" if [true, 'true'].include?(params[:download][:created_at])
		csv << row

		results.each do |participant|
			attribute = JSON.parse(participant['participant_attributes'])
			number    = participant['contact'] ? participant['contact']['value'] : ''
			smkt      = smkts[attribute['role'] || 0]
			creator   = User.find(id: participant['created_by'])
			address   = ''

			if participant['address']
				street      = participant['address']['street'] ? participant['address']['street'].gsub(',', '.') : ''
				city        = participant['address']['city'] ? participant['address']['city'].gsub(',', '.') : ''
				state       = participant['address']['state'] ? participant['address']['state'].gsub(',', '.') : ''
				postal_code = participant['address']['postal_code'] ? participant['address']['postal_code'].gsub(',', '.') : ''
				country     = participant['address']['country'] ? participant['address']['country'].gsub(',', '.') : ''

				address = "#{street} #{city} #{state} #{postal_code}. #{country}"
			end

			row = [
				participant['first_name'],
				participant['last_name'],
				participant['email'],
				number
			]

			row << address if [true, 'true'].include?(params[:download][:with_address])
			row << (attribute['ia_graduate'] ? "Yes" : "No") if [true, 'true'].include?(params[:download][:ia_graduate])
			row << smkt if [true, 'true'].include?(params[:download][:smkt])
			row << participant['gender'] ? "Yes" : "No" if [true, 'true'].include?(params[:download][:gender])
			row << participant['enricher_names'].join(' / ') if [true, 'true'].include?(params[:download][:enrichers])
			row << "#{creator.first_name} #{creator.last_name}" if [true, 'true'].include?(params[:download][:created_by])
			row << participant['created_at'] if [true, 'true'].include?(params[:download][:created_at])
			csv << row
		end

		csv
	end

	def self.get(id, basic_only = false)
		response    = RestClient.get PARBOOK_URL + "/#{id}" + (basic_only ? "/?basic_only=true" : "")
		participant = JSON.parse(response.body)

		unless basic_only
			participant['center']       = Center.find(code: participant['center_code'])
			participant['creator']      = participant['created_by'] ? User.find(id: participant['created_by']) : {}
			participant['events_count'] = EventAttendance.where(member_id: participant['member_id']).exclude(attendance: EventAttendance::REGISTERED)
				.map { |attendance|
					attendance.event_id
				}.compact.uniq.length
			participant['registration_count'] = EventAttendance.where(member_id: participant['member_id'], attendance: EventAttendance::REGISTERED)
				.map { |attendance|
					attendance.event_id
				}.compact.uniq.length
		end


		participant
	end

	def self.create(params)
		response = RestClient.post PARBOOK_URL, params
		JSON.parse(response.body)
	end

	def self.create_comments(id, params)
		response = RestClient.post PARBOOK_URL + "/#{id}/comments", params
		JSON.parse(response.body)
	end

	def self.update_comments(id, comment_id, params)
		response = RestClient.put PARBOOK_URL + "/#{id}/comments/#{comment_id}", params
		JSON.parse(response.body)
	end

	def self.get_events(member_id, attendance_only)
		events = {}

		attendances = EventAttendance.where(member_id: member_id).order(:attendance_date)
		attendances = attendances.exclude(attendance: EventAttendance::REGISTERED) if attendance_only
		attendances.each do |attendance|
			if !events[attendance.event_id.to_s.to_sym]
				event = Event.find(id: attendance.event_id)
				events[attendance.event_id.to_s.to_sym] = JSON.parse(event.to_json)
				events[attendance.event_id.to_s.to_sym]['program'] = event.program
				events[attendance.event_id.to_s.to_sym]['venues']  = []
				events[attendance.event_id.to_s.to_sym]['dates']   = []
			end

			itm = events[attendance.event_id.to_s.to_sym]

			itm['venues'] << attendance.venue_id unless itm['venues'].include? attendance.venue_id
			itm['dates'] << attendance.attendance_date unless itm['dates'].include? attendance.attendance_date
		end

		results = []
		events.each do |key, value|
			value['venues'] = value['venues'].map { |id| Venue.find(id: id) }
			results << value
		end

		[results]
	end

	def self.import_file(creator, file)
		begin
			response = RestClient::Request.execute :method => :post, :url => PARBOOK_URL + "/import_file", :payload => {
				creator: creator,
				upload: file,
				centers: Center.dataset.all.to_json
			}, :timeout => nil, :open_timeout => nil

			response.body
		rescue RestClient::Exception => e
			puts e.inspect
		end
	end

	def self.import_file_sg(creator, file)
		begin
			response = RestClient::Request.execute :method => :post, :url => PARBOOK_URL + "/import_file_singapore", :payload => {
				creator: creator,
				upload: file,
				centers: Center.dataset.all.to_json
			}, :timeout => nil, :open_timeout => nil

			response.body
		rescue RestClient::Exception => e
			puts e.inspect
		end
	end

	def self.update_file(number, file)
		begin
			response = RestClient::Request.execute :method => :post, :url => PARBOOK_URL + "/update_file", :payload => {
				number: number,
				upload: file,
				centers: Center.dataset.all.to_json
			}, :timeout => nil, :open_timeout => nil
		rescue RestClient::Exception => e
			puts e.inspect
		end
	end

	def self.update(id, params)
		response = RestClient.put PARBOOK_URL + "/#{id}", params
		JSON.parse(response.body)
	end

	def self.deleteContact(id, contact_id)
		RestClient.delete PARBOOK_URL + "/#{id}/contact/#{contact_id}"
	end

	def self.deleteAddress(id, address_id)
		RestClient.delete PARBOOK_URL + "/#{id}/address/#{address_id}"
	end

	def self.delete(id)
		RestClient.delete PARBOOK_URL + "/#{id}"
	end

	def self.delete_all
		RestClient.delete PARBOOK_URL + '/delete_all'
	end
end
