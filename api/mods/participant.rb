module Venuebook

	class ParticipantAPI < Grape::API
		namespace "participant" do

			get do
				return Participant.search(params)
			end

			post do
				participant = Participant.create(params)
			end

			put '/:id' do
				participant = Participant.update(params[:id], params)
			end

			delete '/:id' do
				Participant.delete(params[:id])
			end
		end
	end

end

