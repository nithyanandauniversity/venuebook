import { combineReducers } from 'redux'

import participants from './participants';
import centers from './centers';
import programs from './programs';
import venues from './venues';
import downloads from './downloads';
import events from './events';
import users from './users';
import routes from './routes';

const rootReducer = combineReducers({
  participants,
  centers,
  programs,
  venues,
  downloads,
  events,
  users,
  routes
});

export default rootReducer;
