module Venuebook
   class VenueAPI < Grape::API
      format :json
      namespace "venue" do
	 post do 
	    Venue.create(params)
	 end

      end
   end
end
