module Venuebook

	class EventAttendanceAPI < Grape::API
		namespace "event_attendances" do

			before do
				authenticate!
			end

			post do
				if authorize! :create, EventAttendance
					data = params[:attendance]
					data[:created_by] = current_user['id']

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
									data[:confirmation_status] = other_reg.first.confirmation_status
									data[:payment_status]      = other_reg.first.payment_status
									data[:payment_method]      = other_reg.first.payment_method
									data[:amount]              = other_reg.first.amount
									data[:attendance]          = EventAttendance::REGISTERED_AND_ATTENDED
								end
							else
								other_att = record.where(attendance: EventAttendance::NOT_REGISTERED_AND_ATTENDED)
									.exclude(attendance_date: data[:attendance_date])

								if other_att.count > 0
									data[:confirmation_status] = other_att.first.confirmation_status
									data[:payment_status]      = other_att.first.payment_status
									data[:payment_method]      = other_att.first.payment_method
									data[:amount]              = other_att.first.amount
								end
							end

						end
					end

					# puts "\n\nSAVING || #{data.inspect}\n\n"

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

					other_records = EventAttendance.where(member_id: attendance.member_id)
						.exclude(id: attendance.id)

					if other_records.count > 0
						other_records.each do |rec|
							rec.update(
								confirmation_status: attendance.confirmation_status,
								payment_status: attendance.payment_status,
								payment_method: attendance.payment_method,
								amount: attendance.amount
							)
						end
					end

					if params[:send_all]
						return {event_attendances: EventAttendance.all_attendances(attendance[:event_id])}
					else
						return attendance
					end
				end
			end

			delete "/:id" do
				if authorize! :destroy, EventAttendance
					attendance_record = EventAttendance.find(id: params[:id])
					event_id = attendance_record[:event_id]

					if attendance_record[:attendance] == 2
						attendance_record.update(attendance: 1)
					else
						attendance_record.destroy
					end

					return {event_attendances: EventAttendance.all_attendances(event_id)}.to_json()
				end
			end

		end
	end

end

