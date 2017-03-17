
namespace :seed do

	desc "Insert Root Users"
	task :root => :environment do

		User.create(first_name: "Saravana", last_name: "B", email: "sgsaravana@gmail.com", password: "123123", role: 1)
		# User.create(first_name: "Dinesh", last_name: "Gupta", email: "sri.sadhana@innerawakening.org", password: "123123", role: 1)

	end
	desc "Insert Other Users"
	task :users, [:center_id] => :environment do |t, args|

		center_id = args[:center_id]

		User.create(first_name: "Kamlesh", email: "kamlesh@gmail.com", password: "123123", role: 5, center_id: center_id)
		User.create(first_name: "Premteertha", email: "premteertha@gmail.com", password: "123123", role: 5, center_id: center_id)
		User.create(first_name: "Pradeep", email: "shradda@gmail.com", password: "123123", role: 5, center_id: center_id)
		User.create(first_name: "Garima", email: "garima@gmail.com", password: "123123", role: 5, center_id: center_id)
		User.create(first_name: "Durga", email: "durgananda@gmail.com", password: "123123", role: 5, center_id: center_id)
		User.create(first_name: "Phyllis", email: "weemeeai@gmail.com", password: "123123", role: 6, center_id: center_id)

	end
end