export default class ParticipantService {

	constructor(api) {
		this.api        = api;
		this.collection = this.api.all('participants');
		this.url        = this.collection.url();
	}

	reloadApi() {
		this.api.header('Token', sessionStorage.getItem('HTTP_TOKEN'));
		this.collection = this.api.all('participants');
	}

	search(params, callback) {
		let token = sessionStorage.getItem('HTTP_TOKEN');
		console.log("token");
		console.log(token);

		this.reloadApi();
		this.collection.getAll({search: params})
			.then((response) => {
				callback(null, response);
			})
			.catch((err) => {
				callback(err);
			});
	}

	get(id, callback) {
		this.reloadApi();
		this.api.one('participants', id).get()
			.then((response) => {
				callback(null, response);
			})
			.catch((err) => {
				callback(err);
			});
	}

	create(params, callback) {
		this.reloadApi();
		this.collection.post(params)
			.then((response) => {
				callback(null, response);
			})
			.catch((err) => {
				callback(err);
			});
	}

	update(id, params, callback) {
		this.reloadApi();
		this.collection.put(id, params)
			.then((response) => {
				callback(null, response);
			})
			.catch((err) => {
				callback(err);
			});
	}

	removeContact(participant_id, contact_id, callback) {
		this.reloadApi();
		let participant = this.api.one('participants', participant_id);

		participant.delete('contact', contact_id)
			.then((response) => {
				callback(null, response);
			})
			.catch((err) => {
				callback(err);
			});
	}

	removeAddress(participant_id, address_id, callback) {
		this.reloadApi();
		let participant = this.api.one('participants', participant_id);

		participant.delete('address', address_id)
			.then((response) => {
				callback(null, response);
			})
			.catch((err) => {
				callback(err);
			})
	}

	remove(id, callback) {
		this.reloadApi();
		this.collection.delete(id)
			.then((response) => {
				callback(null, response);
			})
			.catch((err) => {
				callback(err);
			});
	}

}
