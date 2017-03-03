module Venuebook

	class EventAttendanceAPI < Grape::API
		namespace "event_attendance" do

			before do
				authenticate!
			end

			post do
				EventAttendance.create(params[:attendance])
			end

			put "/:id" do
				attendance = EventAttendance.find(id: params[:id])
				attendance.update(params[:attendance])
			end

			delete "/:id" do
				attendance = EventAttendance.find(id: params[:id])
				attendance.destroy
			end

		end
	end

end

