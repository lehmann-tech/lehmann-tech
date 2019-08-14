# An unexpected utility of Jest's inline snapshots

> Posted on Monday, January 28, 2019. Code shown is available at [github/theneva/post-utils][code].

I generally avoid Jest's [inline snapshots][inline-snapshots]: If I want a snapshot, it might as well live in its own file to not clutter up the test file, and if the snapshot will be really small, I figure I'm probably better off making an explicit assertion.

I recently discovered one nice case for inline snapshots, though: Lately, I've been writing a lot of filtering and sorting functions for lists.

When testing these functions, I find myself coming back to a certain pattern: I construct a few objects as separate variables and put them in a list in an arbitrary order. Then I run my test subject(s) on that list. Finally, I manually construct a new list that is the expected output, and compare that to the returned list.

For example, given these two sorting functions for (oversimplified) blog posts:

```ts
export type Post = {
  title: string;
  content: string;
};

export function sortByTitle(posts: Post[]) {
  const copy = [...posts];
  return copy.sort((left, right) => left.title.localeCompare(right.title));
}

export function sortByLength(posts: Post[]) {
  const copy = [...posts];
  return copy.sort((left, right) => left.content.length - right.content.length);
}
```

… I might write my tests like this:

```ts
// 1. Import the test subject(s); two sorting functions in this case
import { Post, sortByTitle, sortByLength } from './post-utils';

// 2. Create a few items
const rabbits: Post = {
  title: 'Rabbits',
  content: 'This is a post about rabbits'
};

const dogs: Post = {
  title: 'Dogs',
  content: 'Dogs are great. Shiba Inus in particular.'
};

const frogs: Post = {
  title: 'Frogs',
  content:
    "Frogs are pretty cool. There is one in the video for Vampire Weekend's new song 2021."
};

// 3. Put them all into a list for testing
const posts: Post[] = [dogs, rabbits, frogs];

// 4. Run each function, and compare it to a new array that holds
//    the items in the expected order
test('sort by title', () => {
  const result = sortByTitle(posts);
  const sortedByTitle = [dogs, frogs, rabbits];
  expect(result).toEqual(sortedByTitle);
});

test('sort by length', () => {
  const result = sortByLength(posts);
  const sortedByLength = [rabbits, dogs, frogs];
  expect(result).toEqual(sortedByLength);
});
```

In this example, it's relatively easy to construct the expected results: The test data objects are few and simple, and the functions we're testing are easy to understand.

The real world is messy, though, and the test objects tend to grow in both size, complexity, and number as you test the nuances of your filtering and sorting. If only we had a way to reduce the objects to something simpler, so we could quickly determine the expected order…

Enter inline snapshots! A call with no parameters to the `toMatchInlineSnapshot()` matcher is automatically populated with generated snapshot value on the next test run. If I just want a quick overview of the post titles, I can do this:

```ts
expect(posts.map(post => post.title)).toMatchInlineSnapshot();
```

If you're using Jest's excellent watch mode, this code will immediately be updated to:

```ts
test("sort by title", () => {
  expect(posts.map(post => post.title)).toMatchInlineSnapshot(`
Array [
  "Dogs",
  "Rabbits",
  "Frogs",
]
`);
```

That output maps nicely to the variable names! This output is much easier to sort manually than the complex objects.

For bonus points, we could tack on a `.sort()` after the mapping to let JavaScript do the rest of the manual work:

```ts
expect(posts.map(post => post.title).sort()).toMatchInlineSnapshot(`
Array [
  "Dogs",
  "Frogs",
  "Rabbits",
]
`);
```

The second test is slightly more elaborate. We can extract the length and title of each post, and sort the strings:

```ts
expect(
  posts.map(post => `${post.content.length} ${post.title}`).sort()
).toMatchInlineSnapshot();
```

Let Jest do its thing, and we get:

```ts
expect(posts.map(post => `${post.content.length} ${post.title}`).sort())
  .toMatchInlineSnapshot(`
Array [
  "28 Rabbits",
  "41 Dogs",
  "85 Frogs",
]
`);
```

When we have that, determining the expected order (`[rabbits, dogs, frogs]`) is practically free.

The inline snapshots don't hold any real value for what I wanted to do, so I usually delete them after I'm done—just like I would if I had to resort to `console.log`.

I've found that I can almost always determine the expected result without reimplementing the logic I'm testing: Working with a predefined data set allows me to make assumptions that cannot be made in the actual implementation. I also don't have to care about footguns like mutating the arrays when I'm just looking for the expected output. This all amounts to making the machine do the manual labour—as it should be.

[code]: https://github.com/theneva/post-utils
[inline-snapshots]: https://jestjs.io/docs/en/snapshot-testing#inline-snapshots
