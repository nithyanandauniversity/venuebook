module Venuebook

	class CenterAPI < Grape::API
		namespace "center" do
			post do
				Center.create(params)
			end

			post "/:id/address" do
				center = Center.find(id: params[:id])
				center.add_address(params[:address])
			end

			put "/:id" do
				center = Center.find(id: params[:id])
				center.update(params[:center])
			end

			put "/:id/address/:address_id" do
				center = Center.find(id: params[:id])
				address = center.addresses.find(id: params[:address_id]).first
				address.update(params[:address])
			end

		end
	end

end

