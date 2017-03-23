import { combineReducers } from 'redux'

import participants from './participants';
import centers from './centers';
import programs from './programs';
import venues from './venues';
import events from './events';
import users from './users';
import routes from './routes';

const rootReducer = combineReducers({
  participants,
  centers,
  programs,
  venues,
  events,
  users,
  routes
});

export default rootReducer;
