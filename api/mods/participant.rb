module Venuebook

	class ParticipantAPI < Grape::API
		namespace "participants" do

			before do
				authenticate!
			end

			get do
				if authorize! :read, Participant

					if params[:search]
						params[:search][:center_code] ||= current_user['center_code'] if current_user['role'] >= 3
						puts "Search !!!"
						ext_search = params[:search][:ext_search] || nil

						if ext_search && !ext_search.blank?

							if ext_search[:areas] && ext_search[:areas].length > 0

								params[:search][:center_codes] = Center.get_codes_by_areas(ext_search[:areas])

							elsif ext_search[:countries] && ext_search[:countries].length > 0

								params[:search][:center_codes] = Center.get_codes_by_countries(ext_search[:countries])

							elsif ext_search[:centers] && ext_search[:centers].length > 0

								params[:search][:center_codes] = ext_search[:centers]

							end
						end

						return Participant.search(params)

					elsif params[:download]
						params[:download][:center_code] ||= current_user['center_code'] if current_user['role'] >= 3
						# puts "Download !!!"
						return Participant.download(params)
						# content_type "text/csv"
						# header['Content-Disposition'] = "attachment; filename=yourfilename.csv"
						# env['api.format'] = :binary
						# File.open(file.path).read
					else
						puts "PARAMS HERE !!! #{params.inspect}"
					end

				end
			end

			get '/:id' do
				if authorize! :read, Participant
					return Participant.get(params[:id])
				end
			end

			get '/:id/events' do
				if authorize! :read, Participant
					return Participant.get_events(params[:id], params[:attendance_only])
				end
			end

			post do
				if authorize! :create, Participant
					params[:participant]['created_by'] = current_user['id']
					participant = Participant.create(params)
				end
			end

			post '/:id/comments' do
				if authorize! :update, Participant
					return Participant.create_comments(params[:id], params)
				end
			end

			put '/:id/comments/:comment_id' do
				if authorize! :update, Participant
					return Participant.update_comments(params[:id], params[:comment_id], params)
				end
			end

			# params do
			# 	optional :csv, type: File, desc: 'csv containing users to be invited'
			# end

			# params do
			# 	requires :csv, type: File, desc: 'Participants csv file'
			# end

			post '/import_file' do
				puts params.inspect
				if authorize! :create, Participant
			# 		puts current_user['email']
			# 		puts current_user['center_id']
					puts "params.csv"
					puts params.csv
					# puts params.inspect
					Participant.import_file(current_user['email'], params[:csv])
				end
			end

			put '/:id' do
				if authorize! :update, Participant
					participant = Participant.update(params[:id], params)
				end
			end

			delete '/:id/contacts/:contact_id' do
				if authorize! :update, Participant
					Participant.deleteContact(params[:id], params[:contact_id])
				end
			end

			delete '/:id/addresses/:address_id' do
				if authorize! :update, Participant
					Participant.deleteAddress(params[:id], params[:address_id])
				end
			end

			delete '/:id' do
				if authorize! :destroy, Participant
					Participant.delete(params[:id])
				end
			end

		end
	end

end

