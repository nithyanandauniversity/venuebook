module Venuebook

	class SettingAPI < Grape::API
		namespace "settings" do

			before do
				authenticate!
			end

			get do
				if params[:name]
					setting = Setting.find(name: params[:name])
					[JSON.parse(setting.to_json(:include => [:obj]))]
				else
					settings = Setting.order(:id)
					JSON.parse(settings.to_json(:include => [:obj]))
				end
			end

			post do
				setting = Setting.create(params[:setting])
				JSON.parse(setting.to_json(:include => [:obj]))
			end

			put '/:id' do
				setting = Setting.find(id: params[:id])
				setting.update(params[:setting])
				JSON.parse(setting.to_json(:include => [:obj]))
			end

			delete '/:id' do
				setting = Setting.find(id: params[:id])
				setting.destroy
			end

		end
	end

end

