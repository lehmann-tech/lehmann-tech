const path = require('path');
const fs = require('fs');
const express = require('express');
const app = express();

const readFile = require('./read-file');

app.get('/favicon.ico', (req, res) => res.sendStatus(404));

app.use('/', express.static('public'));

app.get('/posts', (req, res) => {
  return fs.readdir(path.join(__dirname, 'posts'), (err, fileNames) => {
    if (err) {
      console.log(err);
      res.status(500).send('Something went wrong!');
      return;
    }

    const posts = fileNames.map(fileName => ({ title: fileName }));

    res.send(posts);
  });
});

app.get('/posts/:title', (req, res) => {
  const rawTitle = req.params.title;

  const title = rawTitle.endsWith('.md') ? rawTitle : `${rawTitle}.md`;

  const postPath = path.join(__dirname, 'posts', title);

  readFile(postPath)
    .then(markdown => res.send({ markdown }))
    .catch(err => {
      console.log(err);
      return res
        .status(404)
        .send('Could not find a post called "' + title + '.md"');
    });
});

app.listen(5678, err => {
  if (err) throw new Error(err);
  console.log('listening on port', 5678);
});

// Default to always serving up index.html for client-side routing
app.get('*', async (req, res) => {
  const html = await readFile('./public/index.html');
  res.send(html);
});
