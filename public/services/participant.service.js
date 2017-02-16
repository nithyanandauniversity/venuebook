export default class ParticipantService {

	constructor(api) {
		this.collection = api.all('participants');
		this.url = this.collection.url();

		console.log(this.url);
	}


	search(params, callback) {
		this.collection.getAll(params)
			.then((response) => {
				callback(null, response);
			})
			.catch((err) => {
				callback(err);
			});
	}

	get() {}

	find() {}

	create() {}

	update() {}

	remove() {}

}
