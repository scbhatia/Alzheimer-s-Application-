var express     =   require("express");
var app         =   express();
var bodyParser  =   require("body-parser");
var mongoOp     =   require("./models/mongo");
var router      =   express.Router();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({"extended" : false}));

router.get("/",function(req,res){
    res.json({"error" : false,"message" : "Hello World"});
});

router.route("/users")
    // gets all users 
    .get(function(req,res) {
        var response = {};
        mongoOp.find({}, function(err, data) {
            if (err) {
                response = {"error" : true, "message" : "Error fetching data"};
            }
            else {
                response = {"error": false, "message" : data};
            }

            res.json(response);
        })
    })

    // adds specific user
    .post(function(req,res) {

    });

router.route("/users/")
    // gets user with specific phone number and password combo
    .get(function(req, res) {
        
    })

app.use('/',router);

app.listen(3000);
console.log("Listening to PORT 3000");
