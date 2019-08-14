import * as React from 'react';
import { RouteComponentProps } from '@reach/router';

import PostSummary, { PostSummaryType } from './post-summary';

type PostListProps = RouteComponentProps & {};

type PostListState = {
  posts: PostSummaryType[];
};

export default class PostList extends React.PureComponent<
  PostListProps,
  PostListState
> {
  state: PostListState = {
    posts: []
  };

  componentWillMount() {
    fetch('/posts')
      .then(res => res.json())
      .then(posts => this.setState({ posts }));
  }

  render() {
    const { posts } = this.state;

    if (posts.length === 0) {
      return null;
    }

    return (
      <ul>
        {posts.map(post => (
          <li>
            <PostSummary {...post} />
          </li>
        ))}
      </ul>
    );
  }
}
