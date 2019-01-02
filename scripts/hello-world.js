// Description:
//   This script is just a simple hello world
//

module.exports = function (robot) {

    robot.respond(/hello/i, function (msg) {
        msg.send('Hello back!');
    });
};