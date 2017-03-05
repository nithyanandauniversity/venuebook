class Center < Sequel::Model
	self.plugin :timestamps
	one_to_many :venues
	one_to_one :user

	def self.search(params)
		# puts params.inspect
		size       = params && params[:limit].to_i || 10
		page       = params && params[:page].to_i || 1
		keyword    = params && params[:keyword] || nil
		attributes = params && params[:attributes] || nil

		puts "PAGE: #{page} || SIZE: #{size} || KEYWORD: #{keyword}\n\n"

		if keyword || attributes
			# SEARCH
			if keyword
				if attributes
					centers = Center.where((Sequel.like(:name, "%#{keyword}%"))).paginate(page, size)
				else
					centers = Center.where((Sequel.like(:name, "%#{keyword}%"))).paginate(page, size)
					# centers = Center.where("name COLLATE UTF8_GENERAL_CI LIKE ?", "%#{keyword}%")
					# participants = Participant.where("first_name COLLATE UTF8_GENERAL_CI LIKE ? " +
					# 	"OR last_name COLLATE UTF8_GENERAL_CI LIKE ? " +
					# 	"OR other_names COLLATE UTF8_GENERAL_CI LIKE ? " +
					# 	"OR email COLLATE UTF8_GENERAL_CI LIKE ?",
					# 	"'%#{keyword}%'", "'%#{keyword}%'",
					# 	"'%#{keyword}%'", "'%#{keyword}%'"
					# 	).paginate(page, size)
				end
			else
				# participants = Center.where(
				# 	(Sequel.like(:participant_attributes, "%#{attributes.join('%')}%"))
				# ).paginate(page, size)
			end
		else
			# ALL
			centers = Center.dataset.paginate(page, size)
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
