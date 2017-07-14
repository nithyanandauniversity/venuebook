module Venuebook

	class CenterAPI < Grape::API
		namespace "centers" do

			before do
				authenticate!
			end

			get do
				if authorize! :read, Center
					return Center.search(params[:search])
				end
			end

			get '/:id' do
				if authorize! :read, Center
					center = Center.find(id: params[:id])

					return {
						center: center,
						venues: center.venues.collect { |venue|
							JSON.parse(venue.to_json(:include => :address))
						},
						admin: center.admin
					}
				end
			end

			post do
				if authorize! :create, Center

					center = Center.create(params[:center])
					center.update({code: SecureRandom.hex(6)})

					if params[:admin]
						unless User.find_by_email(params[:admin].email)

							admin           = User.new(params[:admin])
							admin.center_id = center.id
							admin.role      = 3
							admin.save

							center
						else
							error!({status: 409, message: "409 Email Conflict"}, 409)
						end
					else
						center
					end
				end
			end

			put "/:id" do
				if authorize! :update, Center
					center = Center.find(id: params[:id])
					center.update(params[:center])

					center.admin.update(params[:admin]) if params[:admin]

					return {
						center: center,
						admin: center.admin
					}
				end
			end

			delete "/:id" do
				if authorize! :destroy, Center
					center = Center.find(id: params[:id])
					center.destroy
				end
			end

		end
	end

end

