export default class ParticipantService {

	constructor(api) {
		this.collection = api.all('participants');
		this.url = this.collection.url();
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

	get(id, callback) {
		this.collection.get(id)
			.then((response) => {
				callback(null, response);
			})
			.catch((err) => {
				callback(err);
			});
	}

	find() {}

	create(params, callback) {
		this.collection.post(params)
			.then((response) => {
				callback(null, response);
			})
			.catch((err) => {
				callback(err);
			});
	}

	update(id, params, callback) {}

	removeContact() {}

	removeAddress() {}

	remove(id, callback) {
		this.collection.delete(id)
			.then((response) => {
				callback(null, response);
			})
			.catch((err) => {
				callback(err);
			});
	}

}
