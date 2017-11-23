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

			all_programs = {}
			creators     = {}
			locations    = []
			coordinators = {}

			data.split('\n').each do |_row|
				CSV.parse(_row) do |row|

					if rcount > 0
						program_name      = row[0]
						program_type      = row[1]
						donation          = row[2]
						start_date        = row[3]
						end_date          = row[4]
						notes             = row[5]
						created_at        = row[6]
						updated_at        = row[7]
						created_by        = row[8]
						event_name        = row[9]
						registration_code = row[10]
						attendances       = JSON.parse("#{row[11]}") || []
						registrations     = JSON.parse("#{row[12]}") || []

						# ASSIGN PROGRAM ID =====================================================================================
						program_id = Events.assign_program_id(program_type, program_name)

						# ASSIGN CREATOR ========================================================================================
						cr = Events.assign_creator(created_by, attendances, registrations)
						puts "CR ::: #{cr}\n\n"
						# creators[created_by] = cr unless creators[created_by]

						# ASSIGN LOCATIONS ======================================================================================
						locs = Events.assign_locations(attendances, registrations)
						locs.each do |l|
							locations << l if l
						end

						# ASSIGN COORDINATORS ===================================================================================
						co = Events.assign_coordinators(attendances, registrations)
						co.each do |k,v|
							coordinators[k] = v unless coordinators[k]
						end

						puts " PRE "
						puts "#{creators}"
						puts "==========\n\n"
						# ASSIGN ATTENDANCE RECORDS =============================================================================
						# event_attendances = Events.assign_attendances(attendances, registrations, center_venues, creators)

						count += 1
					end
					rcount += 1
				end

				puts "CREATORS ::::: #{creators}\n\n"
				puts "LOCATIONS ::::: #{locations.uniq!}\n\n"
				puts "COORDINATORS ::::: #{coordinators}\n\n"
				puts "count :: #{count} || row count :: #{rcount}"
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


		def self.assign_creator(created_by, attendances, registrations)
			ids      = []
			creators = []

			attendances.each do |at|
				ids << at['creator'] unless ids.index(at['creator'])
			end
			registrations.each do |re|
				ids << re['creator'] unless ids.index(re['creator'])
			end

			ids.uniq.each do |id|
				if id
					res   = Participant.get(id.gsub('SG-',''))
					email = res["email"]
					email = "tsytheowlcompany@gmail.com" if email == "tsy.theowlcompany@gmail.com"
					user = User.find(email: email)
					unless user
						creators << email
					end
				else
					creators << "no ID :: #{id}"
				end
			end

			# res     = Participant.get(created_by.gsub('SG-',''))
			# email   = res["email"]
			# email   = "tsytheowlcompany@gmail.com" if email == "tsy.theowlcompany@gmail.com"
			# creator = User.find(email: email)
			creators
		end

		def self.assign_locations(attendances, registrations)
			att = attendances.map { |a| a['location']  } || []
			reg = registrations.map { |r| r['location']  } || []

			locs = []

			att.each do |a|
				locs << a if a
			end

			reg.each do |a|
				locs << a if a
			end

			locs.uniq! || []
		end



		def self.assign_coordinators(attendances, registrations)
			att = attendances.map { |a| a['coordinator']  } || []
			reg = registrations.map { |r| r['coordinator']  } || []

			coo = []
			coordinators = {}

			att.each do |a|
				coo << a if a
			end

			reg.each do |a|
				coo << a if a
			end

			missings = []

			unless coo.nil?
				coo.uniq.each do |co|
					res   = Participant.get(co.gsub('SG-', ''))
					email = res['email']
					email = "tsytheowlcompany@gmail.com" if email == "tsy.theowlcompany@gmail.com"
					email = "premteertha@gmail.com" if email == "ajarananda@gmail.com"
					email = "ma.anupama@innerawakening.org" if email == "nithyadevi.nithyananda@gmail.com"

					coordinator = User.find(email: email)
					if coordinator && !coordinators[co]
						coordinators[co.to_s] = coordinator
					end

					if coordinator.nil?
						missings << email
						puts "\n\nNOT FOUND !!! #{email}\n\n"
					end
				end
			end

			coordinators
		end


		def self.assign_attendances(att, reg, venues, creators)
			data = []

			reg.each do |_reg|
				creator = creators[_reg['creator']]
				puts _reg
				puts creators
				puts creator
				puts "=="
				data << {
					member_id: _reg['member_id'],
					venue_id: _reg['location'] == "Yogam Center" ? venues[0].id : venues[1].id,
					attendance: 1,
					confirmation_status: _reg['attributes']['confirmation_status'],
					payment_status: _reg['attributes']['payment_status'],
					payment_method: _reg['attributes']['payment_method'],
					amount: _reg['attributes']['amount'],
					created_by: creator[:id],# ? creator[:id] : nil,
					created_at: _reg['created_at'],
					updated_at: _reg['updated_at']
				}
			end
			puts "REGISTRATIONS :::"
			puts reg.inspect
			puts "==========================================\n\n"
			puts data.inspect
			puts "==========================================\n\n"
		end


	end

end
