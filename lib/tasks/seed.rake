
namespace :seed do

	desc "Insert Root Users"
	task :root => :environment do

		User.create(first_name: "Saravana", last_name: "B", email: "sgsaravana@gmail.com", password: "123123", role: 1)
		User.create(first_name: "Sadhana", email: "sri.sadhana@innerawakening.org", password: "123123", role: 1)

	end

	desc "Insert Other Users"
	task :users, [:center_id] => :environment do |t, args|

		center_id = args[:center_id]

		User.create(first_name: "Kamlesh", email: "kamlesh@gmail.com", password: "123123", role: 4, center_id: center_id)
		User.create(first_name: "Premteertha", email: "premteertha@gmail.com", password: "123123", role: 4, center_id: center_id)
		User.create(first_name: "Pradeep", email: "shradda@gmail.com", password: "123123", role: 4, center_id: center_id)
		User.create(first_name: "Garima", email: "garima@gmail.com", password: "123123", role: 4, center_id: center_id)
		User.create(first_name: "Durga", email: "durgananda@gmail.com", password: "123123", role: 4, center_id: center_id)
		User.create(first_name: "Phyllis", email: "weemeeai@gmail.com", password: "123123", role: 5, center_id: center_id)

	end

	desc "Insert Settings - Area"
	task :settings_area => :environment do
		areas = ['ANZ', 'Europe-Africa', 'Asia', 'India', 'North America']

		Setting.create(
			name: 'center_areas',
			label: 'Center Areas',
			value: areas.sort.to_json()
		)
	end

	desc "Insert Settings - Program Type"
	task :settings_program => :environment do
		program_types = ['Weekly Event', 'Local Event', 'Bidadi Program', 'Annual Event', 'Temple Activity / Pooja', 'Outdoor Events', 'Other Events']

		Setting.create(
			name: 'program_types',
			label: 'Program Types',
			value: program_types.to_json()
		)
	end
end
