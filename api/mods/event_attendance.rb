module Venuebook

	class EventAttendanceAPI < Grape::API
		namespace "event_attendance" do

			before do
				authenticate!
			end

			post do
				if authorize! :create, EventAttendance
					EventAttendance.create(params[:attendance])
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

