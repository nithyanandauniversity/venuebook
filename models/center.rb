class Center < Sequel::Model
	one_to_many :addresses
end
