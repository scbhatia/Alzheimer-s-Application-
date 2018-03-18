var mongoose    =   require("mongoose");
mongoose.connect('mongodb://localhost:27017/AlzCare');

var mongoSchema =   mongoose.Schema;

var userSchema  = {
    "pat_phone" : String,
    "pat_name" : String,
    "care_phone" : String,
    "care_name" : String,
    "password" : String,
    "address" : String
};

module.exports = mongoose.model('userLogin',userSchema);