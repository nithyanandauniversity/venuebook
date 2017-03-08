module Venuebook
	class ProgramAPI < Grape::API
		namespace "programs" do

			before do
				authenticate!
			end

			get do
				if authorize! :read, Program
					if params[:only_types]
						programs = Program.select(:program_type).distinct
					else
						programs = Program.order(:id)
					end

					if current_user['center_id']
						programs = programs.where(center_id: current_user['center_id']).or(center_id: nil)
					else
						programs = programs.where(center_id: nil)
					end

					[{programs: programs}]
				end
			end

			get '/:id' do
				if authorize! :read, Program
					program = Program.find(id: params[:id])

					return { program: program }
				end
			end

			post do
				if authorize! :create, Program
					params[:program][:center_id] ||= current_user['center_id'] if current_user['center_id']
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