import fetch from 'fetch';
import restful, { fetchBackend } from 'restful';

export default function models() {

	const api = restful('http://localhost:9292/api/v1', fetchBackend(fetch));

	console.log("api");
	console.log(api);

	const participantsCollection = api.all('participants');

	console.log("participantsCollection");
	console.log(participantsCollection, participantsCollection.url());

	// participantsCollection.getAll().then((response) => {
		// console.log(response);
	// });

}