class Address < Sequel::Model
	many_to_one :center
end
