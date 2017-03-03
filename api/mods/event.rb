module Venuebook
	class EventAPI<Grape::API
		namespace "event" do

			before do
				authenticate!
			end

			post do
				Event.create(params[:event])
			end

			post '/:id/venue' do
				event = Event.find(id: params[:id])
				event.add_event_venue(params[:venue])
			end

			put '/:id/venue/:venue_id' do
				event = Event.find(id: params[:id])
				event_venue = event.event_venue(id: params[:venue_id]).first
				event_venue.update(params[:venue])
			end

			delete '/:id/venue/:venue_id' do
				event = Event.find(id: params[:id])
				event_venue = event.event_venue(id: params[:venue_id]).first
				event_venue.destroy
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

