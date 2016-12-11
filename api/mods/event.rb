module Venuebook
   class EventAPI<Grape::API
      namespace "event" do
	 post do
	    event = params[:event]
	    event[:venue] = Venue.find(id:event[:venue].to_i)
	    p params[:event]
	    Event.create(params[:event])
	 end
      end
   end
end

