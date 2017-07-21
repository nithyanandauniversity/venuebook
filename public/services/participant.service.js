export default class ParticipantService {

	constructor(api) {
		this.api        = api;
		this.collection = this.api.all('participants');
		this.url        = this.collection.url();
	}

	reloadApi() {
		this.api.header('Token', sessionStorage.getItem('HTTP_TOKEN'));
		this.api.header('Cache-Control', 'max-age=3600');
		this.collection = this.api.all('participants');
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

	getAttendances(id, callback) {
		this.reloadApi();
		this.api.one('participants', id)
			.all('events')
			.getAll()
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

	createComment(id, params, callback) {
		this.reloadApi();
		this.api.one('participants', id)
			.all('comments')
			.post(params)
			.then((response) => {
				callback(null, response);
			})
			.catch((err) => {
				callback(err);
			});
	}

	import(file, callback) {
		this.reloadApi();
		this.uploadUrl = this.api.custom('participants/import_file')
		console.log("file");
		console.log(file);

		// let xhr = new XMLHttpRequest();

		// $.ajax({
		// 	url         : '/participants/import_file',
		// 	type        : 'POST',
		// 	data        : file,
		// 	cache       : false,
		// 	dataType    : 'json',
		// 	processData : false,
		// 	contentType : 'text/csv',
		// 	headers     : {
		// 		'Token' : sessionStorage.getItem('HTTP_TOKEN')
		// 	},
		// 	success     : (data) => {
		// 		console.log("data");
		// 		console.log(data);
		// 		callback(null, data);
		// 	},
		// 	error       : (err) => {
		// 		console.log("err");
		// 		console.log(err);
		// 		callback(err);
		// 	}
		// });

		// this.uploadUrl.post({csv: file})
		// 	.then((response) => {
		// 		callback(null, response);
		// 	})
		// 	.catch((err) => {
		// 		callback(err);
		// 	});
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
