require 'spec_helper'

describe 'Session API' do
	before(:all) do
		User.dataset.all { |u| u.destroy }
		user = User.create(first_name: "Saravana", last_name: "B", email: "sgsaravana@gmail.com", password: "123123", role: 1)
	end

	it "should be able to login" do

		post "/api/v1/sessions/login", auth: {
			email: "sgsaravana@gmail.com",
			password: "123123"
		}

		response = JSON.parse(last_response.body)
		puts response

		expect(response['token']).not_to eql nil
	end

	it "should return false if wrong password" do

		post "/api/v1/sessions/login", auth: {
			email: "sgsaravana@gmail.com",
			password: "123122"
		}

		response = JSON.parse(last_response.body)

		expect(response['token']).to eql nil
	end

end
