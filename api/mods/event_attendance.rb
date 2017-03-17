module Venuebook

	class EventAttendanceAPI < Grape::API
		namespace "event_attendances" do

			before do
				authenticate!
			end

			post do
				if authorize! :create, EventAttendance
					data = params[:attendance]

					case data[:attendance].to_i
					when EventAttendance::REGISTERED
						registration = EventAttendance.where(
							event_id: data[:event_id],
							member_id: data[:member_id],
							attendance: EventAttendance::REGISTERED
						)

						if registration.count > 0
							if params[:send_all]
								return {event_attendances: EventAttendance.all_attendances(data[:event_id])}
							else
								return registration.first
							end
						end

					when EventAttendance::REGISTERED_AND_ATTENDED
						attendance = EventAttendance.where(
							event_id: data[:event_id],
							member_id: data[:member_id],
							attendance_date: data[:attendance_date],
							attendance: EventAttendance::REGISTERED_AND_ATTENDED
						)

						if attendance.count > 0
							if params[:send_all]
								return {event_attendances: EventAttendance.all_attendances(data[:event_id])}
							else
								return attendance.first
							end
						end
					when EventAttendance::NOT_REGISTERED_AND_ATTENDED
						# Find existing records for the same member_id
						record = EventAttendance.where(event_id: data[:event_id], member_id: data[:member_id])

						if record.count > 0

							# Find records with attendance value with REGISTERED / REGISTERED_AND_ATTENDED
							# If there's any records, the user has registered in advance.
							# registered = record.exclude(attendance: EventAttendance::NOT_REGISTERED_AND_ATTENDED).count > 0

							# Find if records exist for same day
							same_day_attendance = record.where(attendance_date: data[:attendance_date])

							if same_day_attendance.count > 0
								if same_day_attendance.exclude(attendance: EventAttendance::REGISTERED).count > 0
									# If same day records are REGISTERED_AND_ATTENDED / NOT_REGISTERED_AND_ATTENDED Return!
									if params[:send_all]
										return {event_attendances: EventAttendance.all_attendances(data[:event_id])}
									else
										same_day_attendance.exclude(attendance: EventAttendance::REGISTERED).first
									end

								elsif same_day_attendance.where(attendance: EventAttendance::REGISTERED).count > 0
									# If same day record is attendance: REGISTERED then mark record as REGISTERED_AND_ATTENDED
									data[:attendance] = EventAttendance::REGISTERED_AND_ATTENDED

									same_day_registration = same_day_attendance.where(attendance: EventAttendance::REGISTERED).first
									same_day_registration.update(attendance: EventAttendance::REGISTERED_AND_ATTENDED)

									if params[:send_all]
										return {event_attendances: EventAttendance.all_attendances(data[:event_id])}
									else
										return same_day_registration
									end
								else
									puts "HERE !!!"
								end
							end

							# Find if REGISTERED / REGISTERED_AND_ATTENDED on other days.
							other_reg = record.exclude(attendance: EventAttendance::NOT_REGISTERED_AND_ATTENDED)
								.exclude(attendance_date: data[:attendance_date])

							if other_reg.count > 0
								if other_reg.where(attendance: EventAttendance::REGISTERED).count > 0
									registration = other_reg.first

									registration.update(
										attendance: EventAttendance::REGISTERED_AND_ATTENDED,
										attendance_date: data[:attendance_date]
									)

									if params[:send_all]
										return {event_attendances: EventAttendance.all_attendances(data[:event_id])}
									else
										return registration
									end
								else
									data[:attendance] = EventAttendance::REGISTERED_AND_ATTENDED
								end
							end


						end


						# attendance = record.where(attendance: EventAttendance::NOT_REGISTERED_AND_ATTENDED)

						# registration = record.exclude(attendance: EventAttendance::NOT_REGISTERED_AND_ATTENDED)

						# if registration.count > 0
						# 	same_day = registration.where(attendance_date: data[:attendance_date])

						# 	if same_day.count > 0
						# 		event_attendance = same_day.first
						# 		event_attendance.update(attendance: EventAttendance::REGISTERED_AND_ATTENDED)

						# 		if params[:send_all]
						# 			return {event_attendances: EventAttendance.all_attendances(data[:event_id])}
						# 		else
						# 			return event_attendance
						# 		end
						# 	else
						# 		data[:attendance] = EventAttendance::REGISTERED_AND_ATTENDED
						# 	end

						# end

					end

					event_attendance = EventAttendance.create(data)

					if params[:send_all]
						return {event_attendances: EventAttendance.all_attendances(data[:event_id])}
					else
						return event_attendance
					end
				end
			end

			put "/:id" do
				if authorize! :update, EventAttendance
					attendance = EventAttendance.find(id: params[:id])
					attendance.update(params[:attendance])

					if params[:send_all]
						return {event_attendances: EventAttendance.all_attendances(attendance[:event_id])}
					else
						return attendance
					end
				end
			end

			delete "/:id" do
				if authorize! :destroy, EventAttendance
					attendance = EventAttendance.find(id: params[:id])
					event_id = attendance[:event_id]
					attendance.destroy

					return {event_attendances: EventAttendance.all_attendances(event_id)}.to_json()
				end
			end

		end
	end

end

