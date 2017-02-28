module Venuebook

	class ParticipantAPI < Grape::API
		namespace "participants" do

			# before do
			# 	authenticate!
			# end

			get do
				return Participant.search(params)
			end

			get '/:id' do
				return Participant.get(params[:id])
			end

			post do
				participant = Participant.create(params)
			end

			put '/:id' do
				participant = Participant.update(params[:id], params)
			end

			delete '/:id/contact/:contact_id' do
				Participant.deleteContact(params[:id], params[:contact_id])
			end

			delete '/:id/address/:address_id' do
				Participant.deleteAddress(params[:id], params[:address_id])
			end

			delete '/:id' do
				Participant.delete(params[:id])
			end

		end
	end

end

