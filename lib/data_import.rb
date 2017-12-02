require 'rest_client'

module DataImport

	COUNTRIES_YML = HashWithIndifferentAccess.new(YAML.load(File.read(File.expand_path('../countries.yml', __FILE__))))

	module Participants

		def self.generate_countries_list
			countries = []
			COUNTRIES_YML.each do |code, country|
				countries << {
					code: code,
					name: "#{country} (#{code})",
					country: country
				}
			end
			countries
		end

		def self.import(creator, file)
			puts "Module DataImport::Participant.import works !"
			puts "#{PARBOOK_URL}/import_file"
			begin
				response = RestClient.post PARBOOK_URL + "/import_file", {:creator => creator, :upload => file}
				puts response.inspect
			rescue RestClient::Exception => e
				puts e.body
			end
		end

		def self.download(params)
			countries_list = Participants.generate_countries_list()

			response = RestClient.get PARBOOK_URL, {params: {
				download: {
					center_code: params[:center_code],
					with_address: true,
					with_contacts: true
				}
			}}

			results  = JSON.parse(response.body)
			center = Center.find(code: params[:center_code])
			smkts = ["N", "V", "T", "K", "M", "S"]

			CSV.open("participants_#{params[:center_code]}.csv", "w")  do |csv|
				csv << [
					"Member ID", "First name", "Last name", "Gender", "Email Address", "Spiritual Name",
					"Primary contact", "type", "Secondary contact", "type", "IA Graduate?", "IA Dates", "Healer", "SMKT Role",
					"Street", "City", "State", "Postal Code", "Country", "Notes", "Primary center"
				]

				results.each do |par|
					contact1   = par['contacts'][0] || {}
					contact2   = par['contacts'][1] || {}
					address    = par['address'] || {}
					attributes = JSON.parse(par['participant_attributes'])

					csv << [
						par['member_id'], par['first_name'], par['last_name'], par['gender'] ? par['gender'][0] : '', par['email'], par['other_names'],
						contact1['value'], contact1['contact_type'] ? contact1['contact_type'][0] : '', contact2['number'], contact2['contact_type'] ? contact2['contact_type'][0] : '',
						attributes['ia_graduate'] ? "Y" : "N", attributes['ia_dates'], attributes['is_healer'] ? "Y" : "N", smkts[attributes['role'] || 0],
						address['street'], address['city'], address['state'], address['postal_code'], address['country'], par['notes'],
						"#{params[:center_number]} - #{params[:center_code]} - #{center[:name]}"
					]
				end

				csv
			end
		end
	end

	module Centers

		def self.generate_countries_list
			countries = []
			COUNTRIES_YML.each do |code, country|
				countries << {
					code: code,
					name: "#{country} (#{code})",
					country: country
				}
			end
			countries
		end

		def self.import(file)
			data = File.read("#{file}")

			countries_list = Centers.generate_countries_list()

			categories = [
				{
					label: 'Nithyananda Satsang Center',
					value: 'NSC'
				},
				{
					label: 'Nithyananda Paduka Mandhir',
					value: 'NPM'
				},
				{
					label: 'Nithyananda Satsang Temple',
					value: 'NST'
				},
				{
					label: 'Aadheenam',
					value: 'ADH'
				}
			]

			begin
				rcount = 0
				count  = 0
				existing_emails = []

				data.split('\n').each do |_row|
					CSV.parse(_row) do |row|
						puts row.inspect
						if rcount > 0
							country = countries_list.select { |c| c[:name] == row[2] }
							category = categories.select { |c| c[:label] == row[7] }

							center_params = {
								area: row[1],
								country: country[0][:country],
								region: row[3],
								state: row[4],
								city: row[5],
								name: row[6],
								category: category[0][:value],
								code: row[12]
							}

							admin_params = {
								email: row[8],
								first_name: row[9],
								role: 3,
								password: "#{row[11]}#{row[11]}"
							}

							if User.find_by_email(admin_params[:email]).nil?

								center = Center.create(center_params)

								admin_params[:center_id] = center.id

								user = User.create(admin_params)

								count += 1 if center && user
							else
								existing_emails << admin_params[:email]
								puts "\n\n#{admin_params[:email]} Already exists\n"
							end
						end
						rcount += 1
					end
				end

				puts "#{count} records saved / #{rcount - 1} total rows"
				puts "Following emails are duplicates\n#{existing_emails.inspect}"

			rescue Exception => e
				puts e.inspect
			end
		end
	end




	module Events

		def self.import(file)
			data = File.read(file.path)

			rcount = 0
			count  = 0

			center_venues = Center.find(id: 74).venues

			all_programs    = {}
			creators        = {}
			acreators       = {}
			locations       = []
			coordinators    = {}

			missing_records = []
			events          = []

			data.split('\n').each do |_row|
				CSV.parse(_row) do |row|

					if rcount > 0
						program_name      = row[0]
						program_type      = row[1]
						donation          = row[2]
						start_date        = row[3]
						end_date          = row[4]
						notes             = row[5] || ""
						created_at        = row[6]
						updated_at        = row[7]
						created_by        = row[8]
						event_name        = row[9]
						registration_code = row[10]
						attendances       = JSON.parse("#{row[11]}") || []
						registrations     = JSON.parse("#{row[12]}") || []

						# ASSIGN EVENT CREATOR ==================================================================================
						creators[created_by] = Events.assign_creator(created_by) unless creators[created_by]

						# ASSIGN EVENT OBJECT ===================================================================================
						event = {
							name: event_name,
							start_date: start_date,
							notes: notes,
							center_id: 74,
							program_id: Events.assign_program_id(program_type, program_name),
							program_donation: donation,
							registration_code: registration_code,
							created_by: creators[created_by].id,
							created_at: created_at,
							updated_at: updated_at
						}

						# ASSIGN ATTENDANCE CREATORS ============================================================================
						acreators = Events.assign_attendance_creators(acreators, attendances, registrations)

						# ASSIGN EVENT LOCATIONS ================================================================================
						_ev = Events.assign_locations(attendances, registrations, center_venues, event[:notes])
						event[:event_venues] = _ev[0]
						event[:notes]        = _ev[1]

						# ASSIGN ATTENDANCE RECORDS =============================================================================
						event[:event_attendances] = Events.assign_attendances(start_date, attendances, registrations, center_venues, creators, acreators)

						uniq_records = []
						registrations.each do |reg|
							uniq_records << reg['member_id'] unless uniq_records.index reg['member_id']
						end
						attendances.each do |att|
							uniq_records << att['member_id'] unless uniq_records.index att['member_id']
						end
						# puts "\n\n#{event[:event_attendances].length} == #{uniq_records.length}\n\n"

						missing_records << event[:event_attendances] if event[:event_attendances].length != uniq_records.length

						events << event
						count += 1
					end
					rcount += 1
				end

				# puts "CREATORS ::::: #{creators}\n\n"
				# puts "ATTENDANCE CREATORS ::::: #{acreators}\n\n"
				puts "MISSING RECORDS :::::: #{missing_records}\n\n\n"
				puts "count :: #{count} || row count :: #{rcount}\n\n"
				puts "TOTAL EVENT OBJECTS :::>>> #{events.length}\n"

				Events.create_events(events)
			end
		end


		def self.assign_program_id(program_type, program_name)

			program_name_mapping = {
				"Local Event" => {
					"name"  => "Local Event",
					"types" => {
						"3rd Eye Meditation Workshop" => "Special Workshops",
						"Special Workshop"            => "Special Workshops"
					}
				},
				"Weekly Event" => {
					"name"  => "Weekly Event",
					"types" => {
						"Nithya Yoga"                => "Nithya Yoga",
						"Completion Sessions"        => "Completion Sessions",
						"Wealth Completion Sessions" => "Completion Sessions",
						"Nithya Dhyaan"              => "Nithya Dhyaan",
						"Weekend Gurukul"            => "Nithyananda Vidyalaya (NWG)"
					}
				},
				"Temple Activity / Pooja" => {
					"name"  => "Temple Activity / Pooja",
					"types" => {
						"Special Day Poojas"            => "Special Day Pooja",
						"Festival / Celebration Poojas" => "Special Day Pooja"
					}
				},
				"Bidadi Program" => {
					"name"  => "Bidadi Program",
					"types" => {
						"Kalpataru"                     => "Kalpataru",
						"Live Webinar"                  => "Live Webinar",
						"LSP"                           => "Live Webinar",
						"Akashik Readings by Balasants" => "Akashik Reading"
					}
				},
				"Outdoor Event" => {
					"name"  => "Outdoor Events",
					"types" => { "Nithya Yoga" => "Nithya Yoga" }
				},
				"Daily Event" => {
					"name"  => "Local Event",
					"types" => {}
				},
			}


			event_program_type = program_name_mapping["#{program_type}"]["name"]
			event_program_name = program_name_mapping["#{program_type}"]["types"]["#{program_name}"] || "Others"

			program_id = Program.find(program_name: event_program_name, program_type: event_program_type).id
			program_id
		end


		def self.assign_creator(created_by)
			res     = Participant.get(created_by.gsub('SG-',''))
			email   = res["email"]
			email   = "tsytheowlcompany@gmail.com" if email == "tsy.theowlcompany@gmail.com"
			email   = "srinithyasthirananda@gmail.com" if email == "icmprabhakar@gmail.com"
			creator = User.find(email: email)
			creator || nil
		end

		def self.assign_attendance_creators(acreators, attendances, registrations)
			ids = []

			attendances.each { |at| ids << at['creator'] unless ids.index(at['creator']) }
			registrations.each { |re| ids << re['creator'] unless ids.index(re['creator']) }

			ids.uniq.each do |id|
				if id
					res   = Participant.get(id.gsub('SG-',''))
					email = res["email"]
					email = "tsytheowlcompany@gmail.com" if email == "tsy.theowlcompany@gmail.com"
					email = "srinithyasthirananda@gmail.com" if email == "icmprabhakar@gmail.com"
					user  = User.find(email: email)
					if user && !acreators[id]
						acreators[id] = user
					end
				end
			end

			acreators
		end

		def self.assign_locations(attendances, registrations, venues, notes)
			locs = {}

			attendances.each do |att|
				locs[att['location']] = att['coordinator'] if att['coordinator'] && !locs[att['location']]
			end

			registrations.each do |reg|
				locs[reg['location']] = reg['coordinator'] if reg['coordinator'] && !locs[reg['location']]
			end

			locations = []
			locs.each do |location, coordinator|
				notes += "\nLocation: #{location}"
				locations << {
					venue_id: location == "Yogam Center" ? venues[0].id : venues[1].id,
					user_id: Events.get_user(coordinator)
				}
			end

			[locations, notes]
		end

		def self.get_user(coordinator)
			res   = Participant.get(coordinator.gsub('SG-', ''))
			email = res['email']
			email = "tsytheowlcompany@gmail.com" if email == "tsy.theowlcompany@gmail.com"
			email = "premteertha@gmail.com" if email == "ajarananda@gmail.com"
			email = "ma.anupama@innerawakening.org" if email == "nithyadevi.nithyananda@gmail.com"
			email = "srinithyasthirananda@gmail.com" if email == "icmprabhakar@gmail.com"
			user  = User.find(email: email)

			user && user.id || nil
		end

		def self.assign_attendances(start_date, att, reg, venues, creators, acreators)
			data = []

			reg.each do |_reg|
				data << {
					member_id: _reg['member_id'].gsub('SG-',''),
					venue_id: _reg['location'] == "Yogam Center" ? venues[0].id : venues[1].id,
					attendance: 1,
					attendance_date: start_date,
					confirmation_status: _reg['attributes']['confirmation_status'],
					payment_status: _reg['attributes']['payment_status'],
					payment_method: _reg['attributes']['payment_method'],
					amount: _reg['attributes']['amount'],
					created_by: acreators[_reg['creator']][:id],
					created_at: _reg['created_at'],
					updated_at: _reg['updated_at']
				}
			end

			att.each do |_att|
				creator    = acreators[_att['creator']]
				registered = data.find { |d| d[:member_id] == _att['member_id'].gsub('SG-','') }

				if registered
					# EDIT
					registered[:attendance]          = 2
					registered[:confirmation_status] = _att['attributes']['confirmation_status']
					registered[:payment_status]      = _att['attributes']['payment_status']
					registered[:payment_method]      = _att['attributes']['payment_method']
					registered[:amount]              = _att['attributes']['amount']
					registered[:updated_at]          = _att['updated_at']
				else
					# INSERT
					data << {
						member_id: _att['member_id'].gsub('SG-',''),
						venue_id: _att['location'] == "Yogam Center" ? venues[0].id : venues[1].id,
						attendance: 3,
						attendance_date: start_date,
						confirmation_status: _att['attributes']['confirmation_status'],
						payment_status: _att['attributes']['payment_status'],
						payment_method: _att['attributes']['payment_method'],
						amount: _att['attributes']['amount'],
						created_by: creator[:id],# ? creator[:id] : nil,
						created_at: _att['created_at'],
						updated_at: _att['updated_at']
					}
				end
			end

			data
		end


		def self.create_events(events)
			Sequel::Model.db.transaction do
				events.each do |_event|
					params = {
						name: _event[:name],
						start_date: _event[:start_date],
						center_id: _event[:center_id],
						program_id: _event[:program_id],
						notes: _event[:notes],
						uuid: SecureRandom.uuid,
						program_donation: _event[:program_donation],
						registration_code: _event[:registration_code],
						created_by: _event[:created_by],
						created_at: _event[:created_at],
						updated_at: _event[:updated_at]
					}

					event = Event.create(params)

					# venues = []
					_event[:event_venues].each do |_venue|
						# venues << {}
						event.add_event_venue(_venue)
					end

					# event_attendances = []
					_event[:event_attendances].each do |_attendance|
						# event_attendances << {}
						_attendance[:event_id] = event.id
						EventAttendance.create(_attendance)
					end

					puts "EVENT :: #{event.inspect}\n"
					puts "VENUES :: #{_event[:event_venues].inspect}\n"
					puts "ATTENDANCES :: #{_event[:event_attendances].inspect}\n\n"
					puts "========================================================\n"
					puts "#{event.inspect}"
					puts "========================================================\n\n\n"
				end
			end
		end


	end

end
