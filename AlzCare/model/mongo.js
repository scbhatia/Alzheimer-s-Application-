var mongoose    =   require("mongoose");
mongoose.connect('mongodb://localhost:27017/AlzCare');

var mongoSchema =   mongoose.Schema;

var userSchema  = {
    "pat_phone" : String,
    "care_phone" : String,
    "password" : String
};

module.exports = mongoose.model('userLogin',userSchema);