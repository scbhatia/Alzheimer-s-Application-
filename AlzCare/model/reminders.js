var mongoose    =   require("mongoose");
mongoose.connect('mongodb://localhost:27017/AlzCare');

var mongoSchema =   mongoose.Schema;

var rems  = {
    "pat_phone" : String,
    "pic_path" : String,
    "med_name" : String,
    "timeZone": String,
    "time": {type: Date, index: true}
};

module.exports = mongoose.model('Remidners',rems);