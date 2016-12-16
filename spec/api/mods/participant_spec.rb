require 'spec_helper'

describe 'Participant' do

	it "should be able to create participant" do
		post '/api/v1/participant', {first_name:"Saravana", last_name:"Balaraj", email:"sgsaravana@gmail.com", gender:"Male"}

		response = JSON.parse(last_response.body)

		expect(response['first_name']).to eql "Saravana"
		expect(response['last_name']).to eql "Balaraj"
		expect(response['member_id']).not_to eql nil
		expect(response['member_id'].split('-')[0]).to eql Participant.find(id: response['id']).created_at.strftime('%Y%m%d')
	end

	it "should be able to edit participant" do
		participant = Participant.create(first_name:"Saravana", last_name:"Balaraj", email:"sgsaravana@gmail.com", gender:"Male")

		put "api/v1/participant/#{participant.id}", participant: {last_name:"B"}

		response = JSON.parse(last_response.body)

		expect(response['first_name']).to eql "Saravana"
		expect(response['last_name']).to eql "B"
	end

	it "should be able to delete participant" do
		participant = Participant.create(first_name:"Saravana", last_name:"Balaraj", email:"sgsaravana@gmail.com", gender:"Male")

		delete "api/v1/participant/#{participant.id}"

		expect(Participant.find(id: participant.id)).to eql nil
	end

end
