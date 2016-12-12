module Venuebook
	class VenueAPI < Grape::API
		format :json
		namespace "venue" do
			post do 
				Venue.create(params)
			end

			put "/:id" do
				venue = Venue.find(id: params[:id])
				venue.update(params[:venue])
			end

			delete "/:id" do
				venue = Venue.find(id: params[:id])
				venue.destroy
			end

		end
	end
end
