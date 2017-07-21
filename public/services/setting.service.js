export default class SettingService {

	constructor(api) {
		this.api        = api;
		this.collection = this.api.all('settings');
		this.url        = this.collection.url();
	}

	reloadApi() {
		this.api.header('Token', sessionStorage.getItem('HTTP_TOKEN'));
		this.api.header('Cache-Control', 'max-age=3600');
		this.collection = this.api.all('settings');
	}

	get(callback) {
		this.reloadApi();
		this.collection.getAll()
			.then((response) => {
				callback(null, response);
			})
			.catch((err) => {
				callback(err);
			});
	}

	getByName(name, callback) {
		this.reloadApi();
		this.collection.getAll({name: name})
			.then((response) => {
				callback(null, response);
			})
			.catch((err) => {
				callback(err);
			});
	}

}
