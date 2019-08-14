import * as React from 'react';
import { Router } from '@reach/router';

import PostList from './post-list';
import './app.css';
import Post from './post';

const App: React.FC<{}> = () => (
  <Router>
    <PostList path="/" />
    <Post path="/:title" />
  </Router>
);

export default App;
