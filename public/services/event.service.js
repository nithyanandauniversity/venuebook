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

	getUpcoming(params, callback) {
		this.reloadApi();
		this.collection.getAll(params)
			.then((response) => {
				callback(null, response);
			})
			.catch((err) => {
				callback(err);
			});
	}

	getPast(params, callback) {
		this.reloadApi();
		this.collection.getAll({past: params})
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

	getAttendances(id, callback) {
		this.reloadApi();
		this.api.one('events', id)
			.all('event_attendances')
			.getAll()
			.then((response) => {
				callback(null, response);
			})
			.catch((err) => {
				callback(err);
			});
	}

	getAttendanceReport(id, params, callback) {
		this.reloadApi();
		this.api.one('events', id)
			.all('event_attendances')
			.getAll({download: params})
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
