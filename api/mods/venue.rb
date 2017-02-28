module Venuebook
	class VenueAPI < Grape::API
		format :json
		namespace "venue" do
			# before do
			# 	authenticate!
			# end

			post do
				Venue.create(params)
			end

			post "/:id/address" do
				venue = Venue.find(id: params[:id])
				venue.add_address(params[:address])
			end

			put "/:id" do
				venue = Venue.find(id: params[:id])
				venue.update(params[:venue])
			end

			put "/:id/address/:address_id" do
				venue = Venue.find(id: params[:id])
				address = venue.addresses.find(id: params[:address_id]).first
				address.update(params[:address])
			end

			delete "/:id" do
				venue = Venue.find(id: params[:id])
				venue.destroy
			end

			delete "/:id/address/:address_id" do
				venue = Venue.find(id: params[:id])
				address = venue.addresses.find(id: params[:address_id]).first
				address.destroy
			end

		end
	end
end
