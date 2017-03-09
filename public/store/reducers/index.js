import { combineReducers } from 'redux'

import participants from './participants';
import centers from './centers';
import programs from './programs';
import venues from './venues';
import events from './events';
import routes from './routes';

const rootReducer = combineReducers({
  participants,
  centers,
  programs,
  venues,
  events,
  routes
});

export default rootReducer;
