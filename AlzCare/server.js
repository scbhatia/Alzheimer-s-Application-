var express     =   require("express");
var app         =   express();
var bodyParser  =   require("body-parser");
var mongoOp     =   require("./model/mongo");
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

            return res.send(response);
        })
    })

    // adds specific user
    .post(function(req,res) {
        var db = new mongoOp();
        var response = {};

        db.pat_phone = req.body.pat_phone;
        db.care_phone = req.body.care_phone;
        db.password = req.body.password;
        db.pat_name = req.body.pat_name;
        db.care_name = req.body.care_name;
        db.address = req.body.address;

        var query = {
            pat_phone: db.pat_phone,
            pat_name: db.pat_name;
            care_phone: db.care_phone,
            care_name: db.care_name,
            password: db.password,
            address: db.address
        };

        mongoOp.find({query}, function(err, data) {
            if (err) {
                response = {"error" : true, "message" : "Error fetching data"};
                return res.send(response);
            }
            else if (!data) {
                db.save(function(err){
                    if (err) {
                        response = {"error": true, "message": "Error adding data"};
                        return res.send(response);
                    }
                    else {
                        response = {"error": false, "message": "Data added"};
                        return res.send(response);
                    }
                });
            }
            else {
                response = {"error": true, "message": "User already exists!"};
                return res.send(response);
            }
        });

    });

router.route("/users/care/:phone&:password")
    // gets user with specific phone number and password combo
    .get(function(req, res) {
        var response = {};

        let care_phone = req.params.phone;
        let password = req.params.password;

        //return res.send({"phone": care_phone, "pass": password});

        var query = {
            care_phone: care_phone,
            password: password
        };

        //return res.send({query});

        mongoOp.find({query}, function(err, data) {
            if (err) {
                response = {"error": true, "message": "Error fetching data"};

            }
            else if (!data) {
                response = {"error": true, "message": "User does not exist"};
            }
            else {
                response = {"error": false, "message": data};
            }
            return res.send(response);
        });
    });

router.route("/users/pat/:phone&:password")
    // gets user with specific phone number and password combo
    .get(function(req, res) {
        let pat_phone = req.params.phone;
        let password = req.params.password;

        var query = {
            pat_phone: pat_phone,
            password: password
        };

        mongoOp.find({query}, function(err, data) {
            if (err) {
                response = {"error": true, "message": "Error fetching data"};

            }
            else if (!data) {
                response = {"error": true, "message": "User does not exist"};
            }
            else {
                response = {"error": false, "message": data};
            }
            return res.send(response);

        })
    });

app.use('/',router);

app.listen(3000);
console.log("Listening to PORT 3000");
