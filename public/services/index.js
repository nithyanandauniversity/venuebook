import 'fetch';
import restful, { fetchBackend } from 'restful';

// CONSTANTS
import { ROOT, LEAD, CENTER_ADMIN, CENTER_MANAGEMENT, PROGRAM_COORDINATOR, DATA_ENTRY } from '../constants/UserRole.js';
import { COUNTRIES, DIALCODES } from '../constants/countries';
import { CenterCategories } from '../constants/CenterCategory.js';

// SERVICES
import Session from './session.service';
import Participant from './participant.service';
import Center from './center.service';
import Program from './program.service';
import Venue from './venue.service';
import Event from './event.service';
import User from './user.service';

export default class Services {

	constructor() {
		const api = restful('/api/v1', fetchBackend(fetch));

		this.sessionService     = new Session(api);
		this.participantService = new Participant(api);
		this.centerService      = new Center(api);
		this.programService     = new Program(api);
		this.venueService       = new Venue(api);
		this.eventService       = new Event(api);
		this.userService        = new User(api);

		this.countries        = this.generateCountriesList();
		this.dialcodes        = DIALCODES;
		this.centerCategories = CenterCategories;

		this.userRoles        = this.generateUserRoles();

		api.on('error', (error, config, message) => {
			console.log("error, config, message");
			console.log(error.response);
		});
	}

	generateCountriesList() {
		let countries = [];

		for (let code in COUNTRIES) {
			countries.push({
				code  : code,
				value : COUNTRIES[code]
			});
		}

		return function() { return countries; };
	}

	generateUserRoles() {
		return {
			'ROOT'                : ROOT,
			'LEAD'                : LEAD,
			'CENTER_ADMIN'        : CENTER_ADMIN,
			'CENTER_MANAGEMENT'   : CENTER_MANAGEMENT,
			'PROGRAM_COORDINATOR' : PROGRAM_COORDINATOR,
			'DATA_ENTRY'          : DATA_ENTRY
		}
	}


}