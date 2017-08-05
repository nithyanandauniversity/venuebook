require 'csv'

namespace :migrations do

	desc "Import Participants Information"
	task :participants, [:creator, :file] => :environment do |t, args|
		creator   = args[:creator]
		file      = args[:file]

		response  = Participant.import_file(creator, File.open(file))

		CSV.open("errors_list.csv", "w") do |csv|
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

		DataImport::Participant.download(params)
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

end
