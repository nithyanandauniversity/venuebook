require 'rest_client'

class Participant < Sequel::Model
	self.plugin :timestamps
	one_to_many :event_attendances

	def self.search(params)
		response = RestClient.get PARBOOK_URL, {params: params}
		JSON.parse(response.body)
	end

	def self.get(id)
		response    = RestClient.get PARBOOK_URL + "/#{id}"
		participant = JSON.parse(response.body)

		participant['center'] = Center.find(code: participant['center_code'])
		participant
	end

	def self.create(params)
		response = RestClient.post PARBOOK_URL, params
		JSON.parse(response.body)
	end

	def self.import_file(creator, file)
		begin
			response = RestClient::Request.execute :method => :post, :url => PARBOOK_URL + "/import_file", :payload => {
				creator: creator,
				upload: file,
				centers: Center.dataset.all.to_json
			}, :timeout => nil, :open_timeout => nil

			response.body
		rescue RestClient::Exception => e
			puts e.inspect
		end
	end

	def self.import_file_sg(creator, file)
		begin
			response = RestClient::Request.execute :method => :post, :url => PARBOOK_URL + "/import_file_singapore", :payload => {
				creator: creator,
				upload: file,
				centers: Center.dataset.all.to_json
			}, :timeout => nil, :open_timeout => nil

			response.body
		rescue RestClient::Exception => e
			puts e.inspect
		end
	end

	def self.update(id, params)
		response = RestClient.put PARBOOK_URL + "/#{id}", params
		JSON.parse(response.body)
	end

	def self.deleteContact(id, contact_id)
		response = RestClient.delete PARBOOK_URL + "/#{id}/contact/#{contact_id}"
		JSON.parse(response)
	end

	def self.deleteAddress(id, address_id)
		response = RestClient.delete PARBOOK_URL + "/#{id}/address/#{address_id}"
		JSON.parse(response)
	end

	def self.delete(id)
		RestClient.delete PARBOOK_URL + "/#{id}"
	end

	def self.delete_all
		RestClient.delete PARBOOK_URL + '/delete_all'
	end
end
