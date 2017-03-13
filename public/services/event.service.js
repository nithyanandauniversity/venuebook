export default class EventService {

	constructor(api) {
		this.api        = api;
		this.collection = this.api.all('events');
		this.url        = this.collection.url();
	}

	reloadApi() {
		this.api.header('Token', sessionStorage.getItem('HTTP_TOKEN'));
		this.collection = this.api.all('events');
	}

	search(params, callback) {
		this.reloadApi();
		this.collection.getAll({search: params})
			.then((response) => {
				callback(null, response);
			})
			.catch((err) => {
				callback(err);
			});
	}

	getUpcoming(callback) {
		this.collection.getAll({upcoming: true})
			.then((response) => {
				callback(null, response);
			})
			.catch((err) => {
				callback(err);
			});
	}

	get(id, callback) {
		this.reloadApi();
		this.api.one('events', id).get()
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

}