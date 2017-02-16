import 'fetch';
import restful, { fetchBackend } from 'restful';

// import participantService from 'participant.service'; // service file to be created

export default function models() {
	const api = restful('http://localhost:9292/api/v1', fetchBackend(fetch));

	const participantsCollection = api.all('participants');

	console.log(participantsCollection.url());

	participantsCollection.getAll().then((response) => {
		let entities = response.body();

		entities.forEach((entity) => {
			console.log(entity.data());
		});
	})
	.catch((err) => {
		console.log("err");
		console.log(err);
	});

}