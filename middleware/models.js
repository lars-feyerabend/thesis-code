
var mongoose = require('mongoose'),
    Schema = mongoose.Schema,
    ObjectId = Schema.ObjectId;


var Test = new Schema({
    author    : ObjectId
  , title     : String
  , body      : String
  , date      : Date
});

mongoose.model('Test', Test);

var Attempt = new Schema({
    user      : String
  , test      : [Test]
  , cursor    : Number
  , state     : String
  , date      : Date
  , form_url  : String
  , proxy_url : String
  , asset_url : String
});

mongoose.model('Attempt', Attempt);


var Service = new Schema({
    title : String,
    url : String,
    filter_js : Array,
    extra_js : String
});

mongoose.model('Service', Service);