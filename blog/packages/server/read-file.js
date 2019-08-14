const fs = require('fs');

module.exports = function renderMarkdownFile(filePath) {
  return new Promise((resolve, reject) => {
    fs.readFile(filePath, 'utf8', (err, markdown) => {
      if (err) {
        reject(err);
        return;
      }

      resolve(markdown);
    });
  });
};
