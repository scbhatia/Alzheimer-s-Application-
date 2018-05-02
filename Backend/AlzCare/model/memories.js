var mongoose    =   require("mongoose");
mongoose.connect('mongodb://localhost:27017/AlzCare');

var mongoSchema =   mongoose.Schema;

var mems  = {
    "pat_phone" : String,
    "pic_path" : String,
    "title": String,
    "message" : String,
    "timeZone": String,
    "time": {type: Date, index: true}
};

module.exports = mongoose.model('Memories',mems);