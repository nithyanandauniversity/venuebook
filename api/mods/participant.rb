module Venuebook

	class ParticipantAPI < Grape::API
		namespace "participant" do

			get do
				return Participant.search(params[:search])
			end

			post do
				participant = Participant.create(params)
				member_id = participant.created_at.strftime('%Y%m%d') + '-' + SecureRandom.hex(4)
				participant.update(member_id: member_id)
			end

			put '/:id' do
				participant = Participant.find(id: params[:id])
				participant.update(params[:participant])
			end

			delete '/:id' do
				participant = Participant.find(id: params[:id])
				participant.destroy
			end
		end
	end

end

