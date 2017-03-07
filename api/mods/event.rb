module Venuebook
	class EventAPI<Grape::API
		namespace "event" do

			before do
				authenticate!
			end

			post do
				if authorize! :create, Event
					Event.create(params[:event])
				end
			end

			post '/:id/venue' do
				if authorize! :create, Venue
					event = Event.find(id: params[:id])
					event.add_event_venue(params[:venue])
				end
			end

			put '/:id/venue/:venue_id' do
				if authorize! :update, Venue
					event = Event.find(id: params[:id])
					event_venue = event.event_venue(id: params[:venue_id]).first
					event_venue.update(params[:venue])
				end
			end

			delete '/:id/venue/:venue_id' do
				if authorize! :destroy, Venue
					event = Event.find(id: params[:id])
					event_venue = event.event_venue(id: params[:venue_id]).first
					event_venue.destroy
				end
			end

			put "/:id" do
				if authorize! :update, Event
					event = Event.find(id: params[:id])
					event.update(params[:event])
				end
			end

			delete "/:id" do
				if authorize! :destroy, Event
					event = Event.find(id: params[:id])
					event.destroy
				end
			end
		end
	end
end

