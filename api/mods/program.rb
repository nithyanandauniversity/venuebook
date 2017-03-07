module Venuebook
	class ProgramAPI < Grape::API
		namespace "programs" do

			before do
				authenticate!
			end

			get do
				if authorize! :read, Program
					if current_user['center_id']
						Program.where(center_id: current_user['center_id']).or(center_id: nil)
					else
						Program.where(center_id: nil)
					end
				end
			end

			post do
				if authorize! :create, Program
					program = Program.create(params[:program])
					program
				end
			end


			put '/:id' do
				if authorize! :update, Program
					program = Program.find(id: params[:id])
					if current_user['center_id']
						if program[:center_id] && current_user['center_id'] == program[:center_id]
							program.update(params[:program])
							program
						else
							error!({status: 403, message: "Access Denied"}, 403)
						end
					else
						program.update(params[:program])
						program
					end
				end
			end

			delete '/:id' do
				if authorize! :destroy, Program
					program = Program.find(id: params[:id])
					if current_user['center_id']
						if program[:center_id] && current_user['center_id'] == program[:center_id]
							program.destroy
						else
							error!({status: 403, message: "Access Denied"}, 403)
						end
					else
						program.destroy
					end
				end
			end

		end
	end
end