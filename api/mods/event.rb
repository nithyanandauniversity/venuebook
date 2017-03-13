module Venuebook
	class EventAPI<Grape::API
		namespace "events" do

			before do
				authenticate!
			end

			get do
				if authorize! :read, Event

					if params[:upcoming]
						return Event.where('start_date > ?', (Date.today - 1.day))
					elsif params[:past]

						page = params[:past] && params[:past][:page].to_i || 1
						size = params[:past] && params[:past][:limit].to_i || 10

						events = Event.filter('start_date < ?', (Date.today - 1.day))
							.order(:start_date)
							.paginate(page, size)

						[{
							events: events,
							page_count: events.page_count,
							page_size: events.page_size,
							page_range: events.page_range,
							current_page: events.current_page,
							pagination_record_count: events.pagination_record_count,
							current_page_record_count: events.current_page_record_count,
							current_page_record_range: events.current_page_record_range,
							first_page: events.first_page?,
							last_page: events.last_page?
						}]
					end
				end
			end

			post do
				if authorize! :create, Event
					event    = Event.create(params[:event])
					reg_code = (event.id * 5 * 6 * 7 * 8).to_s(36)
					uuid     = SecureRandom.uuid
					event.update(uuid: uuid, registration_code: reg_code)

					if params[:venues] && params[:venues].length > 0
						params[:venues].each do |v|
							event.add_event_venue(v)
						end
					end

					event
				end
			end

			post '/:id/venue' do
				if authorize! :create, Venue
					event = Event.find(id: params[:id])
					event.add_event_venue(params[:venue])
					event
				end
			end

			put '/:id/venue/:venue_id' do
				if authorize! :update, Venue
					event = Event.find(id: params[:id])
					event_venue = event.event_venues(id: params[:venue_id]).first
					event_venue.update(params[:venue])
					event
				end
			end

			delete '/:id/venue/:venue_id' do
				if authorize! :destroy, Venue
					event = Event.find(id: params[:id])
					event_venue = event.event_venues(id: params[:venue_id]).first
					event_venue.destroy
				end
			end

			put "/:id" do
				if authorize! :update, Event
					event = Event.find(id: params[:id])
					event.update(params[:event])
					event
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

