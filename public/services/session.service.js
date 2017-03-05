export default class SessionService {

	constructor(api) {
		this.api   = api;
		this.login = this.api.custom('sessions/login');
		this.url   = this.login.url();
	}

	// reloadApi() {
	// 	this.api.header('Token', sessionStorage.getItem('HTTP_TOKEN'));
	// 	this.auth = this.api.custom('sessions/authenticate');
	// }

	authenticate(callback){
		this.api.header('Token', sessionStorage.getItem('HTTP_TOKEN'));
		this.auth = this.api.custom('sessions/authenticate');
		this.auth.get()
			.then((response) => {
				callback(null, response.body());
			})
			.catch((err) => {
				callback(err);
			});
	}

	doLogin(params, callback) {
		this.login.post(params)
			.then((response) => {
				callback(null, response);
			})
			.catch((err) => {
				callback(err);
			});
	}

}