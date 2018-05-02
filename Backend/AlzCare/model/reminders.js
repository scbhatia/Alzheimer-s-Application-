var mongoose    =   require("mongoose");
const moment    =   require("moment");
const Twilio    =   require("twilio");

mongoose.connect('mongodb://localhost:27017/AlzCare');

var twilioAccountSid='AC5cc5db3a5ff30e8fc43bf107e135be10'
var twilioAuthToken='9f72a387d392dab2695f193da75efa43'
var twilioPhoneNumber='+12156080357'

const rems  = new mongoose.Schema ({
    "pat_phone" : String,
    "pic_path" : String,
    "title" : String,
    "description" : String,
    "notification" : Number,
    "timeZone": String,
    "time": {type: Date, index: true}
});

rems.methods.requiresNofitication = function(date) {
    return Math.round(moment.duration(moment(this.time).tz(this.timeZone).utc()
            .diff(moment(date).utc())).asMinutes()) === this.notification;
};

rems.statics.sendNofitications = function(callback) {
    const searchDate = new Date();
    Reminders
        .find()
        .then(function(reminders) {
            reminders = reminders.filter(function(reminders) {
                return reminders.requiresNofitication(searchDate);
            });
            if (reminders.length > 0) {
                sendNotifications(reminders);
            }
        });

        /**
         * @param {array} reminders
         */

        function sendNofitications(reminders) {
            const client = new Twilio(twilioAccountSid, twilioAuthToken);
            reminders.forEach(function(appointment) {
                const options = {
                    to: `+ 1${reminders.pat_phone}`,
                    from: twilioPhoneNumber,
                    body: `${reminders.title} ${reminders.description}`,
                };

                client.messages.create(options, function(err, response) {
                    if (err) {
                        console.error(err);
                    }
                    else {

                    }
                });
            });

            if (callback) {
                callback.call();
            }
        }
};

const Reminders = mongoose.model('reminder', rems);
module.exports(Reminders);