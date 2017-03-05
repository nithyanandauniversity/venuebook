module Venuebook

	class CenterAPI < Grape::API
		namespace "centers" do

			before do
				authenticate!
			end

			get do
				return Center.search(params[:search])
			end

			get '/:id' do
				center = Center.find(id: params[:id])

				{
					center: center,
					admin: center.admin
				}
			end

			post do
				center = Center.create(params[:center])

				admin           = User.new(params[:admin])
				admin.center_id = center.id
				admin.role      = 3
				admin.save

				center
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

