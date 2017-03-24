class Center < Sequel::Model
	self.plugin :timestamps
	one_to_many :venues
	one_to_one :user

	def leads
		all_leads  = User.where(role: 2)

		return {
			area: JSON.parse(all_leads.where((Sequel.ilike(:permissions, "%areas%#{area}%"))).to_json(:only => [:id, :first_name, :last_name, :email])),
			country: JSON.parse(all_leads.where((Sequel.ilike(:permissions, "%countries%#{country}%"))).to_json(:only => [:id, :first_name, :last_name, :email])),
			center: JSON.parse(all_leads.where((Sequel.ilike(:permissions, "%centers%#{id}%"))).to_json(:only => [:id, :first_name, :last_name, :email]))
		}

	end

	def self.search(params)
		# puts params.inspect
		size       = params && params[:limit].to_i || 10
		page       = params && params[:page].to_i || 1
		keyword    = params && params[:keyword] || nil
		attributes = params && params[:attributes] || nil

		# puts "KEYWORD :: #{keyword} || ATTRIBUTES :: #{attributes}\n\n\n"

		if (keyword && !keyword.blank?) || (attributes && !attributes.blank?)
			# SEARCH
			if !keyword.blank?
				if attributes && !attributes.blank?
					centers = Center.order(:id)
					centers = centers.where(region: attributes.region) if attributes.region
					centers = centers.where(area: attributes.area) if attributes.area
					centers = centers.where(country: attributes.country) if attributes.country
					centers = centers.where(city: attributes.city) if attributes.city
					centers = centers.where(state: attributes.state) if attributes.state
					centers = centers.where(category: attributes.category) if attributes.category
					centers = centers.where((Sequel.ilike(:name, "%#{keyword}%"))).paginate(page, size)
				else
					centers = Center.where(
						(Sequel.ilike(:name, "%#{keyword}%")) |
						(Sequel.ilike(:region, "%#{keyword}%")) |
						(Sequel.ilike(:area, "%#{keyword}%")) |
						(Sequel.ilike(:country, "%#{keyword}%")) |
						(Sequel.ilike(:city, "%#{keyword}%")) |
						(Sequel.ilike(:state, "%#{keyword}%")) |
						(Sequel.ilike(:category, "%#{keyword}%"))
					).paginate(page, size)
				end
			else
				centers = Center.order(:id)
				centers = centers.where(region: attributes.region) if attributes.region
				centers = centers.where(area: attributes.area) if attributes.area
				centers = centers.where(country: attributes.country) if attributes.country
				centers = centers.where(city: attributes.city) if attributes.city
				centers = centers.where(state: attributes.state) if attributes.state
				centers = centers.where(category: attributes.category) if attributes.category

				centers = centers.paginate(page, size)
			end
		else
			# ALL
			centers = Center.order(:id).paginate(page, size)
		end

		[{
			centers: centers,
			page_count: centers.page_count,
			page_size: centers.page_size,
			page_range: centers.page_range,
			current_page: centers.current_page,
			pagination_record_count: centers.pagination_record_count,
			current_page_record_count: centers.current_page_record_count,
			current_page_record_range: centers.current_page_record_range,
			first_page: centers.first_page?,
			last_page: centers.last_page?
		}]
	end

	def admin
		User.find({center_id: id, role: 3})
	end
end
