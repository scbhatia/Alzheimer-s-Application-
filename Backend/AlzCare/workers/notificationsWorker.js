'use strict';

var mems = require('../models/memories');
var rems = require('../models/reminders');

const notificationWorkerFactory = function() {
    return {
        run: function() {
            mems.sendNotifications();
            rems.sendNotifications();
        },
    };
};

module.exports = notificationWorkerFactory();