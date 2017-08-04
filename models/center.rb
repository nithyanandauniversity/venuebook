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

	def self.get_codes_by_areas(areas)
		codes = Center.where("area IN ?", areas).map { |center|
			center.code if center.code
		}.compact

		codes
	end

	def self.get_codes_by_countries(countries)
		codes = Center.where("country IN ?", countries).map { |center|
			center.code if center.code
		}.compact

		codes
	end

	def self.search(params, current_user)
		# puts params.inspect
		size       = params && params[:limit].to_i || 10
		page       = params && params[:page].to_i || 1
		keyword    = params && params[:keyword] || nil
		attributes = params && params[:attributes] || nil
		selection  = params && params[:center_selection] || false

		# puts "KEYWORD :: #{keyword} || ATTRIBUTES :: #{attributes}\n\n\n"

		if selection
			user = User.find(id: current_user['id'])
			if user.role == 2
				puts user.allowed_center_list.inspect
				centers = user.allowed_center_list
			else
				centers = Center.order(:id)
			end
		else
			centers = Center.order(:id)
		end

		if (keyword && !keyword.blank?) || (attributes && !attributes.blank?)
			# SEARCH
			if !keyword.blank?
				if attributes && !attributes.blank?
					# centers = Center.order(:id)
					centers = centers.where(region: attributes.region) if attributes.region
					centers = centers.where(area: attributes.area) if attributes.area
					centers = centers.where(country: attributes.country) if attributes.country
					centers = centers.where(city: attributes.city) if attributes.city
					centers = centers.where(state: attributes.state) if attributes.state
					centers = centers.where(category: attributes.category) if attributes.category
					centers = centers.where((Sequel.ilike(:name, "%#{keyword}%"))).paginate(page, size)
				else
					centers = centers.where(
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
				# centers = Center.order(:id)
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
			centers = centers.order(:id).paginate(page, size)
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
