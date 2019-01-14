// Description:
//   This script returns help for hubot
//

module.exports = function (robot) {

    robot.respond(/help/i, async function (msg) {
        msg.send('*' + robot.name + ' hello* - _This command will reply with greetings._');
    });
};