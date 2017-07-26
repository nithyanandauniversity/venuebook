require 'csv'

class Event < Sequel::Model
	self.plugin :timestamps
	one_to_many :event_venues
	one_to_many :event_attendances
	many_to_many :venues, :left_key => :event_id, :right_key => :venue_id, :join_table => :event_venues
	many_to_many :users, :left_key => :event_id, :right_key => :user_id, :join_table => :event_venues
	many_to_one :program


	def creator
		if created_by && User.find(id: created_by)
			User.find(id: created_by)
		else
			{}
		end
	end

	def get_attendance_csv(params)

		smkts = ["None", "Volunteer", "Thanedar", "Kotari", "Mahant", "Sri Mahant"]
		payment_status_options = ['Not Paid', 'Partial', 'Full Paid']
		payment_method_options = ['Cash', 'Cheque', 'Bank', 'Online', 'Coupon']

		# CSV.generate do |csv|
		csv = []
		csv << [
			"#",
			"First Name",
			"Last Name",
			"Spiritual Name",
			"SMKT",
			"Gender",
			"Address",
			"City",
			"Email Address",
			"Contact Numbers",
			# "Status",
			# "Enricher",
			"Payment Status",
			"Amount",
			"Payment Method",
			"Venue"
		]

		records = EventAttendance.where(event_id: id).where("attendance IN ?", [2,3])
		records = records.where(venue_id: params[:venue_id]) if !params[:venue_id].blank?
		records = records.where(attendance_date: params[:attendance_date]) if !params[:attendance_date].blank?

		record_group = {}

		count = 0

		puts records.inspect

		records.each do |record|
			if !record_group[record[:member_id].to_s]
				participant = Participant.get(record[:member_id])
				record_group[record[:member_id].to_s] = {
					venues: [],
					dates: [],
					participant: participant,
					participant_attributes: JSON.parse(participant['participant_attributes']),
					record: record
				}
			end

			venue = Venue.find(id: record[:venue_id])
			record_group[record[:member_id].to_s][:venues] << venue[:name]
			record_group[record[:member_id].to_s][:dates] << record[:attendance_date]
		end

		record_group.each do |key, record|
			participant            = record[:participant]
			venues                 = record[:venues].uniq
			participant_attributes = record[:participant_attributes]
			data                   = record[:record]
			address                = participant['addresses'][0]

			count += 1

			csv << [
				count,
				participant['first_name'], participant['last_name'], participant['other_names'],
				smkts[participant_attributes['role'] || 0], participant['gender'],
				"#{address['street']} #{address['city']} #{address['state']} #{address['postal_code']} #{address['coutnry']}".gsub(',', '.'),
				address['city'].gsub(',','.'),
				participant['email'], participant['contacts'][0]['value'],
				payment_status_options[data[:payment_status] || 0],
				data[:amount],
				payment_method_options[data[:payment_method] || 0],
				venues.join(',')
			]
		end
		# end

		csv
	end
end
