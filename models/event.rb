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
			User.select(:id, :first_name, :last_name).where(id: created_by).first
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
			"Payment Status",
			"Amount",
			"Payment Method",
			"Pre-Registered",
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
				participant['email'],
				participant['contacts'][0] ? participant['contacts'][0]['value'] : '',
				payment_status_options[data[:payment_status] || 0],
				data[:amount],
				payment_method_options[data[:payment_method] || 0],
				data[:attendance] === 2 ? "Yes" : "No",
				venues.join(',')
			]
		end
		# end

		csv
	end





	def self.import_file_sg(file)
		DataImport::Events.import(file)
		# data = File.read(file.path)

		# rcount = 0
		# count  = 0

		# program_name_mapping = {
		# 	"Local Event" => {
		# 		"name"  => "Local Event",
		# 		"types" => {
		# 			"3rd Eye Meditation Workshop" => "Special Workshops",
		# 			"Special Workshop"            => "Special Workshops"
		# 		}
		# 	},
		# 	"Weekly Event" => {
		# 		"name"  => "Weekly Event",
		# 		"types" => {
		# 			"Nithya Yoga"                => "Nithya Yoga",
		# 			"Completion Sessions"        => "Completion Sessions",
		# 			"Wealth Completion Sessions" => "Completion Sessions",
		# 			"Nithya Dhyaan"              => "Nithya Dhyaan",
		# 			"Weekend Gurukul"            => "Nithyananda Vidyalaya (NWG)"
		# 		}
		# 	},
		# 	"Temple Activity / Pooja" => {
		# 		"name"  => "Temple Activity / Pooja",
		# 		"types" => {
		# 			"Special Day Poojas"            => "Special Day Pooja",
		# 			"Festival / Celebration Poojas" => "Special Day Pooja"
		# 		}
		# 	},
		# 	"Bidadi Program" => {
		# 		"name"  => "Bidadi Program",
		# 		"types" => {
		# 			"Kalpataru"                     => "Kalpataru",
		# 			"Live Webinar"                  => "Live Webinar",
		# 			"LSP"                           => "Live Webinar",
		# 			"Akashik Readings by Balasants" => "Akashik Reading"
		# 		}
		# 	},
		# 	"Outdoor Event" => {
		# 		"name"  => "Outdoor Events",
		# 		"types" => { "Nithya Yoga" => "Nithya Yoga" }
		# 	},
		# 	"Daily Event" => {
		# 		"name"  => "Local Event",
		# 		"types" => {}
		# 	},
		# }

		# all_names = []
		# all_types = []

		# all_programs = {}

		# data.split('\n').each do |_row|
		# 	CSV.parse(_row) do |row|

		# 		if rcount > 0
		# 			program_name      = row[0]
		# 			program_type      = row[1]
		# 			donation          = row[2]
		# 			start_date        = row[3]
		# 			end_date          = row[4]
		# 			notes             = row[5]
		# 			created_at        = row[6]
		# 			created_by        = row[7]
		# 			updated_at        = row[8]
		# 			created_by        = row[9]
		# 			event_name        = row[10]
		# 			registration_code = row[11]

		# 			attendances       = row[12]
		# 			registrations     = row[13]

		# 			unless all_programs.key?("#{program_type}")
		# 				all_programs["#{program_type}"] = []
		# 			end

		# 			unless all_programs["#{program_type}"].index("#{program_name}")
		# 				all_programs["#{program_type}"] << program_name
		# 			end


		# 			unless all_names.index("#{program_name}")
		# 				all_names << program_name
		# 			end

		# 			unless all_types.index("#{program_type}")
		# 				all_types << program_type
		# 			end

		# 			count += 1
		# 		end
		# 		rcount += 1
		# 	end

		# 	puts "ALL NAMES :: #{all_names.inspect}\n"
		# 	puts "ALL TYPES :: #{all_types.inspect}\n\n\n"
		# 	puts "HASH ::::: #{all_programs}\n\n\n"
		# 	puts "count :: #{count} || row count :: #{rcount}"
		# end
	end
end
