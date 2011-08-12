var restify = require('restify');

var client = restify.createClient({
  url: 'https://localhost:3000',
  version: '1.2.3',
  retryOptions: {
    retries: 2,
    minTimeout: 250
  }
});

client.get('/your/foo/bar', function(err, body, headers) {
  if (err)
    return console.log(err);

  console.log('Body: ' + JSON.stringify(body, null, 2));
  console.log('Headers: ' + JSON.stringify(headers, null, 2));
});
// 
// var req = {
//   path: '/mark/update',
//   body: {
//     foo: 'bar'
//   },
//   query: {
//     action: 'addAttribute'
//   },
//   expect: [200, 201, 202, 204]
// };
// client.post(req, function(err, body, headers) {
//   if (err)
//     console.log(err);
// });
// client.head('/mark', function(err, headers) {
//   if (err)
//     return console.log(err);
// 
//   console.log('Headers: ' + JSON.stringify(headers, null, 2));
// });