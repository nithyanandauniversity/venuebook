module Venuebook

	class ParticipantAPI < Grape::API
		namespace "participants" do

			before do
				authenticate!
			end

			get do
				if authorize! :read, Participant
					if current_user['role'] >= 3
						params[:search][:center_code] ||= current_user['center_code']
					# elsif current_user['role'] == 3
						# params[:search][:center_code] ||= current_user['center_code']
					end

					return Participant.search(params)
				end
			end

			get '/:id' do
				if authorize! :read, Participant
					return Participant.get(params[:id])
				end
			end

			post do
				if authorize! :create, Participant
					participant = Participant.create(params)
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

			delete '/:id/contact/:contact_id' do
				if authorize! :update, Participant
					Participant.deleteContact(params[:id], params[:contact_id])
				end
			end

			delete '/:id/address/:address_id' do
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

