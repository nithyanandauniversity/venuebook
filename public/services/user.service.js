export default class UserService {

	constructor(api) {
		this.api        = api;
		this.collection = this.api.all('users');
		this.url        = this.collection.url();
	}

	reloadApi() {
		this.api.header('Token', sessionStorage.getItem('HTTP_TOKEN'));
		this.collection = this.api.all('users');
	}

	find(params, callback){
		this.reloadApi();
		this.collection.getAll(params)
			.then((response) => {
				callback(null, response);
			})
			.catch((err) => {
				callback(err);
			});
	}

}