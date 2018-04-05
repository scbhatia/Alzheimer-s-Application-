var express     =   require("express");
var app         =   express();
var bodyParser  =   require("body-parser");
var mongoOp     =   require("./model/mongo");
var router      =   express.Router();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({"extended" : false}));

///////////////////////// User Management System ////////////////////////////////
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
        db,pat_name = req.body.pat_name;
        db.care_name = req.body.care_name;
        db.address = req.body.address;

        mongoOp.find({pat_phone: db.pat_phone, care_phone: db.care_phone, password: db.password, pat_name: db.pat_name, care_name: db.care_name, address: db.address}, function(err, data) {
            if (err) {
                response = {"error" : true, "message" : "Error fetching data"};
                return res.send(response);
            }
            else if (!data.length) {
                console.log(data.length);
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
        })

    });

// for patient login
router.route("/users/pat/:phone&:password")
    // gets user with specific phone number and password combo
    .get(function(req, res) {
        
        let pat_phone = req.params.phone;
        let password = req.params.password;

        mongoOp.find({pat_phone: pat_phone, password: password}, function(err, data) {
            if (err) {
                response = {"error": true, "message": "Error fetching data"};

            }
            else if (!data.length) {
                response = {"error": true, "message": "User does not exist"};
            }
            else {
                response = {"error": false, "message": "Patient login successful!"};
            }
            return res.send(response);

        })
    });

router.route("/users/care/:phone&:password")
    // gets user with specific phone number and password combo
    .get(function(req, res) {
        
        let care_phone = req.params.phone;
        let password = req.params.password;

        mongoOp.find({care_phone: care_phone, password: password}, function(err, data) {
            if (err) {
                response = {"error": true, "message": "Error fetching data"};

            }
            else if (!data.length) {
                response = {"error": true, "message": "User does not exist"};
            }
            else {
                response = {"error": false, "message": "Caregiver login successful!"};
            }
            return res.send(response);

        })
    });
///////////////////////// End User Management System /////////////////////////////

////////////////////////////// Reminders System //////////////////////////////////

/////////////////////////////// End Reminders System /////////////////////////////

app.use('/',router);

app.listen(3000);
console.log("Listening to PORT 3000");
