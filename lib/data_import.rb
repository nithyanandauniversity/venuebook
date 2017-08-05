require 'rest_client'

module DataImport

	COUNTRIES_YML = HashWithIndifferentAccess.new(YAML.load(File.read(File.expand_path('../countries.yml', __FILE__))))

	module Participant

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
			countries_list = Participant.generate_countries_list()

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

end
