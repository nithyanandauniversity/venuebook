module Venuebook

	class EventAttendanceAPI < Grape::API
		namespace "event_attendance" do
			post do
				EventAttendance.create(params[:attendance])
			end

			# post "/:id/address" do
			# 	center = Center.find(id: params[:id])
			# 	center.add_address(params[:address])
			# end

			put "/:id" do
				attendance = EventAttendance.find(id: params[:id])
				attendance.update(params[:attendance])
			end

			# put "/:id/address/:address_id" do
			# 	center = Center.find(id: params[:id])
			# 	address = center.addresses.find(id: params[:address_id]).first
			# 	address.update(params[:address])
			# end

			delete "/:id" do
				attendance = EventAttendance.find(id: params[:id])
				attendance.destroy
			end

			# delete "/:id/address/:address_id" do
			# 	center = Center.find(id: params[:id])
			# 	address = center.addresses.find(id: params[:address_id]).first
			# 	address.destroy
			# end

		end
	end

end

