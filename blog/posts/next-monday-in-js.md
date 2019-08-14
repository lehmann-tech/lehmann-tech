# Get the date of the next Monday in JS

With plain JS:

```js
function nextMondayDateString() {
  // Get the current date for math purposes later.
  const now = new Date();
  
  // 1. Starting from from the current date…
  const nextMonday = new Date(); 
 
  // 2. Subtract the current week day to get the first day of the current week (Sunday)
  // 3. Add 1 to get the date of the current week's Monday
  // 4. Add 7 to get the date of next week's Monday
  nextMonday.setDate(now.getDate() - now.getDay() + 8); // 8 = 1 + 7

  // Format it as required. This yields DD.MM.YYYY
  return `${nextMonday.getDate()}.${nextMonday.getMonth()}.${nextMonday.getFullYear()}`;
}
```

Alternatively, if you already have [Moment.js](https://momentjs.com/) in your project and need [.day()](https://momentjs.com/docs/#/get-set/day/) :

```
moment().day(8).format('DD.MM.YYYY');
```
