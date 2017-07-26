module Venuebook
	class EventAPI<Grape::API
		namespace "events" do

			before do
				authenticate!
			end

			get do
				if authorize! :read, Event

					if params[:upcoming]

						center_id = current_user['role'] < 3 ? params[:center_id] : current_user['center_id']

						events = Event.where(center_id: center_id)
							.where('start_date > ?', (Date.today - 1.day))
							.order(:start_date)

						[{events: JSON.parse(events.to_json(:include => :program))}]

					elsif params[:past]

						page      = params[:past] && params[:past][:page].to_i || 1
						size      = params[:past] && params[:past][:limit].to_i || 10
						center_id = current_user['role'] < 3 ? params[:past][:center_id] : current_user['center_id']

						events = Event.where(center_id: center_id)
							.filter('start_date <= ?', (Date.today - 1.day))
							.reverse(:start_date)
							.paginate(page, size)

						[{
							events: JSON.parse(events.to_json(:include => :program)),
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

			get '/:id' do
				if authorize! :read, Event

					center_id = current_user['role'] < 3 ? params[:center_id] : current_user['center_id']
					event     = Event.find(id: params[:id])

					if current_user['role'] != 1 && event.center_id != center_id.to_i
						# error!({status: 401, message: "401 Unauthorized"}, 401)
						error!({status: 403, message: "Access Denied"}, 403)
					else
						program      = event.program
						event_venues = EventVenue.where(event_id: event.id).collect { |event_venue|
							venue               = event_venue.venue
							venue[:address]     = venue.address
							event_venue[:venue] = venue
							event_venue[:user]	= event_venue.user
							event_venue
						}

						{
							event: JSON.parse(event.to_json()),
							creator: event.creator,
							program: program,
							event_venues: event_venues,
							attendances: EventAttendance.all_attendances(event.id)
						}
					end
				end
			end

			get '/:id/event_attendances' do
				if authorize! :read, EventAttendance
					if params[:download]
						event = Event.find(id: params[:id])
						event.get_attendance_csv(params[:download])
					else
						[{event_attendances: EventAttendance.all_attendances(params[:id])}]
					end
				end
			end

			post do
				if authorize! :create, Event
					event    = Event.create(params[:event])
					creator  = current_user['id']
					reg_code = (event.id * 5 * 6 * 7 * 8).to_s(36)
					uuid     = SecureRandom.uuid
					event.update(uuid: uuid, registration_code: reg_code, created_by: creator)

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

					if params[:venues] && params[:venues].length > 0
						event.event_venues.each { |e| e.destroy }

						params[:venues].each do |v|
							event.add_event_venue(v)
						end
					end

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

