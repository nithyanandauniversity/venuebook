require 'spec_helper'

describe 'Settings API' do
	before(:all) do
		Setting.dataset.all { |s| s.destroy }
		User.dataset.all { |u| u.destroy }
		user = User.create(first_name: "Saravana", last_name: "B", email: "sgsaravana@gmail.com", password: "123123", role: 1)

		post "/api/v1/sessions/login", {auth: {
			email: "sgsaravana@gmail.com",
			password: "123123"
		}}

		response = JSON.parse(last_response.body)
		@token   = response['token']
	end

	it "should be able to create new setting" do
		setting = {
			name: 'center_regions',
			label: 'Regions',
			value: ['North America', 'Asia Pacific', 'Europe', 'South Asia', 'Africa'].to_json()
		}

		post "/api/v1/settings", {setting: setting}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)

		expect(response['id']).not_to eql nil
		expect(response['name']).to eql 'center_regions'
		expect(response['obj'].length).to eql 5
	end

	it "should be able to list all settings" do

		get "/api/v1/settings", nil, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)

		expect(response.length).not_to eql 0
	end

	it "should be able to get setting by name" do

		setting = {
			name: 'center_areas',
			label: 'Areas',
			value: ['West Coast', 'Mid West', 'Hollywood'].to_json()
		}

		post "/api/v1/settings", {setting: setting}, {'HTTP_TOKEN' => @token}

		get "/api/v1/settings", {name: 'center_areas'}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)[0]

		expect(response['name']).to eql 'center_areas'
		expect(response['label']).to eql 'Areas'
	end

	it "should be able to edit a setting" do

		setting = {
			name: 'center_areas',
			label: 'Areas',
			value: ['West Coast', 'Mid West', 'Hollywood'].to_json()
		}

		post "/api/v1/settings", {setting: setting}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)
		expect(response['obj'].length).to eql 3

		put "/api/v1/settings/#{response['id']}", {
			setting: {
				value: ['West Coast', 'Mid West', 'Hollywood', 'East Coast'].to_json()
			}
		}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)

		expect(response['obj'].length).to eql 4
	end

	it "should be able to remove setting" do

		setting = {
			name: 'center_areas',
			label: 'Areas',
			value: ['West Coast', 'Mid West', 'Hollywood'].to_json()
		}

		post "/api/v1/settings", {setting: setting}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)
		count    = Setting.count


		delete "/api/v1/settings/#{response['id']}", nil, {'HTTP_TOKEN' => @token}

		expect(Setting.count).to eql count - 1

	end

end
