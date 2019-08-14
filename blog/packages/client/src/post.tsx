import * as React from 'react';
import { RouteComponentProps } from '@reach/router';
import marked from 'marked';
import highlight from 'highlight.js';

marked.setOptions({
  highlight: code => highlight.highlightAuto(code).value,
});

type PostProps = RouteComponentProps<{ title: string }>;

type PostType = {
  markdown: string;
};

type PostState = {
  post: PostType | null;
};

class Post extends React.PureComponent<PostProps, PostState> {
  state: PostState = {
    post: null,
  };

  componentWillMount() {
    const { title } = this.props;

    fetch(`/posts/${title}`)
      .then(res => res.json())
      .then(post => {
        this.setState({ post });
      });
  }

  render() {
    const { post } = this.state;

    if (post == null) {
      return null;
    }

    return (
      <div
        className="container"
        dangerouslySetInnerHTML={{ __html: marked(post.markdown) }}
      />
    );
  }
}

export default Post;
