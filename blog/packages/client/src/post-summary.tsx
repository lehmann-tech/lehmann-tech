import * as React from 'react';
import { Link } from '@reach/router';

export type PostSummaryType = {
  title: string;
};

const PostSummary: React.FC<PostSummaryType> = ({ title }) => (
  <div>
    <Link to={`/${title}`}>{title}</Link>
  </div>
);

export default PostSummary;
