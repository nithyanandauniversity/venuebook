module Venuebook
   class Venue < Grape::API
      namespace "venue" do
	 post do 
	    params
	 end

	 get do
	    "Hello from venue"
	 end
      end
   end
end
