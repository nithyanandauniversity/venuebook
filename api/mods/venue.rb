module Venuebook
	class VenueAPI < Grape::API
		format :json
		namespace "venue" do

			before do
				authenticate!
			end

			post do
				Venue.create(params)
			end

			post "/:id/address" do
				if authorize! :create, Address
					venue = Venue.find(id: params[:id])
					venue.add_address(params[:address])
				end
			end

			put "/:id" do
				if authorize! :update, Venue
					venue = Venue.find(id: params[:id])
					venue.update(params[:venue])
				end
			end

			put "/:id/address/:address_id" do
				if authorize! :update, Address
					venue = Venue.find(id: params[:id])
					address = venue.addresses.find(id: params[:address_id]).first
					address.update(params[:address])
				end
			end

			delete "/:id" do
				if authorize! :destroy, Venue
					venue = Venue.find(id: params[:id])
					venue.destroy
				end
			end

			delete "/:id/address/:address_id" do
				if authorize! :destroy, Address
					venue   = Venue.find(id: params[:id])
					address = venue.addresses.find(id: params[:address_id]).first
					address.destroy
				end
			end

		end
	end
end
