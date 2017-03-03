module Venuebook

	class CenterAPI < Grape::API
		namespace "center" do

			before do
				authenticate!
			end

			post do
				Center.create(params)
			end

			put "/:id" do
				center = Center.find(id: params[:id])
				center.update(params[:center])
			end

			delete "/:id" do
				center = Center.find(id: params[:id])
				center.destroy
			end

		end
	end

end

