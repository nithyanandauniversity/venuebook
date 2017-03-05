import { combineReducers } from 'redux'

import participants from './participants';
import centers from './centers';
import routes from './routes';

const rootReducer = combineReducers({
  participants,
  centers,
  routes
});

export default rootReducer;
