
namespace :seed do

	desc "Insert Root Users"
		task :root => :environment do

			User.create(first_name: "Saravana", last_name: "B", email: "sgsaravana@gmail.com", password: "123123", role: 1)
			User.create(first_name: "Dinesh", last_name: "Gupta", email: "sri.sadhana@innerawakening.org", password: "123123", role: 1)

		end
end