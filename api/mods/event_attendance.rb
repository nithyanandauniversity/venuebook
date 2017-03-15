module Venuebook

	class EventAttendanceAPI < Grape::API
		namespace "event_attendances" do

			before do
				authenticate!
			end

			post do
				if authorize! :create, EventAttendance
					data = params[:attendance]

					if data[:attendance].to_i == EventAttendance::NOT_REGISTERED_AND_ATTENDED
						attendance = EventAttendance
								.where(event_id: data[:event_id], member_id: data[:member_id])
								.exclude(attendance: EventAttendance::NOT_REGISTERED_AND_ATTENDED)

						if attendance.count > 0
							same_day = attendance.where(attendance_date: data[:attendance_date])

							if same_day.count > 0
								event_attendance = same_day.first
								event_attendance.update(attendance: EventAttendance::REGISTERED_AND_ATTENDED)
								return event_attendance
							else
								data[:attendance] = EventAttendance::REGISTERED_AND_ATTENDED
							end

						end

					end

					return EventAttendance.create(data)
				end
			end

			put "/:id" do
				if authorize! :update, EventAttendance
					attendance = EventAttendance.find(id: params[:id])
					attendance.update(params[:attendance])
				end
			end

			delete "/:id" do
				if authorize! :destroy, EventAttendance
					attendance = EventAttendance.find(id: params[:id])
					attendance.destroy
				end
			end

		end
	end

end

