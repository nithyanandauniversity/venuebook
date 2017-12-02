require 'csv'

namespace :migrations do

	desc "Import Participants Information"
	task :participants, [:creator, :file] => :environment do |t, args|
		creator   = args[:creator]
		file      = args[:file]

		user = User.find(email: creator)

		unless user
			puts "CREATOR (#{creator}) NOT FOUND !"
			return
		else
			response  = Participant.import_file(user.id, File.open(file))

			CSV.open("errors_list.csv", "w") do |csv|
				response.force_encoding("UTF-8").split('\n').each do |_row|
					_row = _row.gsub(/\\"/,"")
					_row = _row.gsub(/\\'/,"")
					row = _row.split(',')
					csv << row
				end
			end
		end

	end

	desc "Update Participants Information"
	task :participants_update, [:number, :file] => :environment do |t, args|
		number = args[:number]
		file   = args[:file]

		response  = Participant.update_file(number, File.open(file))

		CSV.open("update_errors_list.csv", "w") do |csv|
			response.force_encoding("UTF-8").split('\n').each do |_row|
				_row = _row.gsub(/\\"/,"")
				_row = _row.gsub(/\\'/,"")
				row = _row.split(',')
				csv << row
			end
		end
	end

	desc "Download all Participants in Template for update"
	task :download_for_update, [:number, :code] => :environment do |t, args|
		params = {
			center_number: args[:number],
			center_code: args[:code]
		}

		DataImport::Participants.download(params)
	end

	desc "Import Participants Information from Singapore"
	task :participants_sg, [:creator, :file] => :environment do |t, args|
		creator   = args[:creator]
		file      = args[:file]

		response  = Participant.import_file_sg(creator, File.open(file))

		CSV.open("errors_list_sg.csv", "w") do |csv|
			response.force_encoding("UTF-8").split('\n').each do |_row|
				_row = _row.gsub(/\\"/,"")
				_row = _row.gsub(/\\'/,"")
				row = _row.split(',')
				csv << row
			end
		end
	end

	desc "Import All Centers Information"
	task :centers, [:file] => :environment do |t, args|
		file = args[:file]

		DataImport::Centers.import(file)
	end


	desc "Import all past events from SG Database"
	task :events_sg, [:file] => :environment do |t, args|
		file = args[:file]

		response = Event.import_file_sg(File.open(file))
	end

end
