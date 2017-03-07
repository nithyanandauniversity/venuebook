require 'spec_helper'

describe 'Program API' do

	before(:all) do
		User.dataset.all { |u| u.destroy }
		user = User.create(first_name: "Saravana", last_name: "B", email: "sgsaravana@gmail.com", password: "123123", role: 1)

		post "/api/v1/sessions/login", {auth: {
			email: "sgsaravana@gmail.com",
			password: "123123"
		}}

		response = JSON.parse(last_response.body)
		@token   = response['token']

		Program.dataset.all { |p| p.destroy }
	end

	it "should be able to create global programs" do

		post "/api/v1/programs", {program: {
			program_name: "Nithya Yoga",
			program_type: "Weekly Event"
		}}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)

		expect(response['id']).not_to eql nil
		expect(response['program_name']).to eql "Nithya Yoga"
		expect(response['center_id']).to eql nil
	end

	it "should be able to list global programs" do
		Program.create(program_name: "Nithya Dhyan", program_type: "Weekly Event")

		get "/api/v1/programs", nil, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)

		expect(response.length).to eql 2
	end

	it "should be able to edit global programs" do
		program = Program.create(program_name: "webinar", program_type: "Bidadi Program")

		put "/api/v1/programs/#{program.id}", {program: {
			program_name: "Live Webinar"
		}}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)

		expect(response['program_name']).to eql "Live Webinar"
	end

	it "should be able to delete global programs" do
		program = Program.create(program_name: "home visit", program_type: "Local Program")

		count = Program.count

		delete "/api/v1/programs/#{program.id}", nil, {'HTTP_TOKEN' => @token}

		expect(Program.find(id: program.id)).to eql nil
		expect(Program.count).to eql count - 1
	end


	it "should be able to create center programs" do
		center = Center.create(name: "Yogam", state: "Singapore", country: "Singapore", code: "123")
		ca1    = User.create(first_name: "Center admin1", email: "centeradmin1@gmail.com", password: "123123", role: 3, center_id: center.id)

		post "/api/v1/sessions/login", {auth: {
			email: "centeradmin1@gmail.com",
			password: "123123"
		}}

		token = JSON.parse(last_response.body)['token']

		post "/api/v1/programs", {program: {
			program_name: "Nithya Yoga",
			program_type: "Weekly Event",
			center_id: center.id
		}}, {'HTTP_TOKEN' => token}

		response = JSON.parse(last_response.body)

		expect(response['program_name']).to eql "Nithya Yoga"
		expect(response['center_id']).not_to eql nil
	end

	it "should be able to list global and center programs" do

		center = Center.create(name: "Yogam", state: "Singapore", country: "Singapore", code: "123")
		ca1    = User.create(first_name: "Center admin1", email: "centeradmin1@gmail.com", password: "123123", role: 3, center_id: center.id)

		post "/api/v1/sessions/login", {auth: {
			email: "centeradmin1@gmail.com",
			password: "123123"
		}}

		token = JSON.parse(last_response.body)['token']

		get "/api/v1/programs", nil, {'HTTP_TOKEN' => token}

		response = JSON.parse(last_response.body)

		expect(response.length).not_to eql 0
	end

	it "should be able to edit center programs" do
		center  = Center.create(name: "Yogam", state: "Singapore", country: "Singapore", code: "123")
		ca2     = User.create(first_name: "Center admin1", email: "centeradmin2@gmail.com", password: "123123", role: 3, center_id: center.id)

		post "/api/v1/sessions/login", {auth: {
			email: "centeradmin2@gmail.com",
			password: "123123"
		}}

		token   = JSON.parse(last_response.body)['token']
		program = Program.create(program_name: "webinar", program_type: "Bidadi Program", center_id: center.id)

		put "/api/v1/programs/#{program.id}", {program: {
			program_name: "Live Webinar"
		}}, {'HTTP_TOKEN' => token}

		response = JSON.parse(last_response.body)

		expect(response['program_name']).to eql "Live Webinar"
	end

	it "should not allow to edit global programs" do
		center  = Center.create(name: "Yogam", state: "Singapore", country: "Singapore", code: "123")
		ca3     = User.create(first_name: "Center admin1", email: "centeradmin3@gmail.com", password: "123123", role: 3, center_id: center.id)

		post "/api/v1/sessions/login", {auth: {
			email: "centeradmin3@gmail.com",
			password: "123123"
		}}

		token   = JSON.parse(last_response.body)['token']
		program = Program.create(program_name: "webinar", program_type: "Bidadi Program")

		put "/api/v1/programs/#{program.id}", {program: {
			program_name: "Live Webinar"
		}}, {'HTTP_TOKEN' => token}

		response = JSON.parse(last_response.body)

		expect(response['status']).to eql 403
		expect(response['message']).to eql "Access Denied"
	end

	it "should be able to delete center programs" do
		center  = Center.create(name: "Yogam", state: "Singapore", country: "Singapore", code: "123")
		ca4     = User.create(first_name: "Center admin1", email: "centeradmin4@gmail.com", password: "123123", role: 3, center_id: center.id)

		post "/api/v1/sessions/login", {auth: {
			email: "centeradmin4@gmail.com",
			password: "123123"
		}}

		token   = JSON.parse(last_response.body)['token']
		program = Program.create(program_name: "webinar", program_type: "Bidadi Program", center_id: center.id)

		count = Program.count

		delete "/api/v1/programs/#{program.id}", nil, {'HTTP_TOKEN' => token}

		expect(Program.find(id: program.id)).to eql nil
		expect(Program.count).to eql count - 1
	end

	it "should not allow center admin to delete global program" do
		center  = Center.create(name: "Yogam", state: "Singapore", country: "Singapore", code: "123")
		ca5     = User.create(first_name: "Center admin1", email: "centeradmin5@gmail.com", password: "123123", role: 3, center_id: center.id)

		post "/api/v1/sessions/login", {auth: {
			email: "centeradmin5@gmail.com",
			password: "123123"
		}}

		token   = JSON.parse(last_response.body)['token']
		program = Program.create(program_name: "webinar", program_type: "Bidadi Program")

		delete "/api/v1/programs/#{program.id}", nil, {'HTTP_TOKEN' => token}

		response = JSON.parse(last_response.body)

		expect(response['status']).to eql 403
		expect(response['message']).to eql "Access Denied"
	end

end
