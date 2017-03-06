require 'spec_helper'

describe 'User API' do
	before(:all) do
		User.dataset.all { |u| u.destroy }
		user = User.create(first_name: "Saravana", last_name: "B", email: "sgsaravana@gmail.com", password: "123123", role: 1)

		post "/api/v1/sessions/login", auth: {
			email: "sgsaravana@gmail.com",
			password: "123123"
		}

		response = JSON.parse(last_response.body)
		@token   = response['token']
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
