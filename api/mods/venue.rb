module Venuebook
	class VenueAPI < Grape::API
		format :json
		namespace "venues" do

			before do
				authenticate!
			end

			get do
				if authorize! :read, Venue
					if params[:center_id] && current_user['center_id'] == params[:center_id].to_i
						venues = Venue.where(center_id: params[:center_id])

						[{ venues: JSON.parse(venues.to_json(:include => :address)) }]
					end
				end
			end

			get '/:id' do
				if authorize! :read, Venue
					venue = Venue.find(id: params[:id])

					{
						venue: venue,
						address: venue.address
					}
				end
			end

			post do
				if authorize! :create, Venue

					if current_user['role'] == 3
						params[:venue][:center_id] ||= current_user['center_id']
					end

					venue = Venue.create(params[:venue])
					if authorize! :create, Address
						venue.add_address(params[:address]) if params[:address]
					end
					venue
				end
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
					if authorize! :update, Address
						venue.address.update(params[:address]) if params[:address]
					end
					venue.update(params[:venue])
					venue
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
