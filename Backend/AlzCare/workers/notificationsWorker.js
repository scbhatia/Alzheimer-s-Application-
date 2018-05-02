'use strict';

var Reminders   =   require("./model/reminders");

const notificationWorkerFactory = function() {
    return {
        run: function() {
            Reminders.sendNotifications();
        },
    };
};

module.exports = notificationWorkerFactory();