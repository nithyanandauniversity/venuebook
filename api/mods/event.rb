module Venuebook
	class EventAPI<Grape::API
		namespace "event" do
			post do
				event = params[:event]
				event[:venue] = Venue.find(id:event[:venue].to_i)
				Event.create(params[:event])
			end

			put "/:id" do
				event = Event.find(id: params[:id])
				event.update(params[:event])
			end

			delete "/:id" do
				event = Event.find(id: params[:id])
				event.destroy
			end
		end
	end
end

