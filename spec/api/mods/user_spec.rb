require 'spec_helper'

describe 'User API' do
	before(:all) do
		User.dataset.all { |u| u.destroy }
		@user = User.create(first_name: "Saravana", last_name: "B", email: "sgsaravana@gmail.com", password: "123123", role: 1)

		post "/api/v1/sessions/login", auth: {
			email: "sgsaravana@gmail.com",
			password: "123123"
		}

		response = JSON.parse(last_response.body)
		@token   = response['token']
	end

	it "should be able to search for users" do
		center = Center.create(name: "Singapore Aadheenam")
		User.create(first_name: "centeradmin1", email: "centeradmin1@gmail.com", password: "123123", role: 3, center_id: center.id)
		User.create(first_name: "centermanager1", email: "centermanager1@gmail.com", password: "123123", role: 4, center_id: center.id)
		User.create(first_name: "coordinator1", email: "coordinator1@gmail.com", password: "123123", role: 4, center_id: center.id)
		User.create(first_name: "dataentry", email: "dataentry@gmail.com", password: "123123", role: 5, center_id: center.id)

		post "/api/v1/sessions/login", auth: {
			email: "centermanager1@gmail.com",
			password: "123123"
		}

		response = JSON.parse(last_response.body)
		token   = response['token']

		get "/api/v1/users/", {search_coordinators: true}, {'HTTP_TOKEN' => token}

		response = JSON.parse(last_response.body)[0]['users']

		expect(response.length).to eql 3
	end

	it "should be albe to find user by email address" do

		get "/api/v1/users", {email: "centeradmin1@gmail.com"}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)[0]['user']

		expect(response['email']).to eql "centeradmin1@gmail.com"

		get "/api/v1/users", {email: "sfdgvasregvrfg@gmail.com"}, {'HTTP_TOKEN' => @token}

		response = JSON(last_response.body)[0]['user']

		expect(response).to eql nil
	end

	it "should be able to get the current user" do

		get "/api/v1/users/current_user", nil, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)

		expect(response['email']).to eql nil
		expect(response['role']).to eql 1
	end

	it "should be able to create a new root user" do

		post "/api/v1/users", {user: {
			first_name: "Ma Jnanatma",
			email: "ma.jnanatma@nithyananda.org",
			password: "123123",
			role: 1
		}}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)

		expect(response['id']).not_to eql nil
		expect(response['email']).to eql "ma.jnanatma@nithyananda.org"
		expect(response['role']).to eql 1
	end

	it "should be able to create a PROGRAM COORDINATOR or DATA ENTRY level user with a center_id" do

		post "/api/v1/users", {
			user: {
				first_name: "Program coordinator1",
				email: "programcoordinator111@gmail.com",
				role: 4,
				password: "123123122"
			}
		}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)

		expect(response['id']).not_to eql nil
		expect(response['role']).to eql 4
		expect(response['email']).to eql "programcoordinator111@gmail.com"

		post "/api/v1/users", {
			user: {
				first_name: "Data Entry1",
				email: "dataentry111@gmail.com",
				role: 5,
				password: "123123122"
			}
		}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)

		expect(response['id']).not_to eql nil
		expect(response['role']).to eql 5
		expect(response['email']).to eql "dataentry111@gmail.com"
	end

	it "should be able to create a LEAD level user with permissions" do
		Center.dataset.all { |c| c.destroy }

		post "/api/v1/users", {
			user: {
				first_name: "Lead1",
				email: "leaduser111@gmail.com",
				role: 2,
				permissions: {
					areas: ['ANZ', 'Asia']
				}.to_json(),
				password: "123123122"
			}
		}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)

		user = User.find(id: response['id'])

		expect(response['id']).not_to eql nil
		expect(response['user_permissions']).not_to eql nil
		expect(response['user_permissions']['areas'].length).to eql 2
		expect(user.allowed_centers.length).to eql 0

		center1 = Center.create(area: 'ANZ', name: 'Melbourne Aadheenam')
		center2 = Center.create(area: 'SEA', name: 'Singapore Aadheenam')

		user.reload
		expect(user.allowed_centers.length).to eql 1

		expect(center1.leads).not_to eql nil
		expect(center1.leads[:area].length).to eql 1
	end

	it "should respond with 401 if the current password is wrong" do
		put "/api/v1/users/change_password/#{@user.id}", {
			user: {
				old_password: "1231233",
				password: "112233"
			}
		}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)

		expect(response['status']).to eql 401
	end

	it "should be able to change password" do

		put "/api/v1/users/change_password/#{@user.id}", {
			user: {
				old_password: "123123",
				password: "112233"
			}
		}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)

		expect(response['id']).to eql @user.id
	end

	it "should be able to create a new lead user with specific access" do

		post "/api/v1/users", {user: {
			first_name: "Ma Atmadaya",
			email: "ma.atmadaya@nithyananda.org",
			password: "123123",
			role: 2
			}}, {'HTTP_TOKEN' => @token}

			response = JSON.parse(last_response.body)

			expect(response['id']).not_to eql nil
			expect(response['email']).to eql "ma.atmadaya@nithyananda.org"
			expect(response['role']).to eql 2
	end

end
