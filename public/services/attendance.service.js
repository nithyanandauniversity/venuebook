export default class AttendanceService {

	constructor(api) {
		this.api   = api;
		this.login = this.api.custom('event_attendances');
		this.url   = this.login.url();
	}

	reloadApi() {
		this.api.header('Token', sessionStorage.getItem('HTTP_TOKEN'));
		this.api.header('Cache-Control', 'max-age=3600');
		this.collection = this.api.all('event_attendances');
	}

	get(id, callback) {
		this.reloadApi();
		this.api.one('event_attendances', id).get({version : Date.now()})
			.then((response) => {
				callback(null, response);
			})
			.catch((err) => {
				callback(err);
			});
	}

	search(params, callback) {
		this.reloadApi();
		this.collection.getAll(params)
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

