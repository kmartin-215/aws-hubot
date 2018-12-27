let Fs          = require('fs');
let Path        = require('path');

module.exports = function(robot) {

    let scriptsPath = Path.resolve(__dirname, 'scripts');
    let helpPath = Path.resolve(__dirname, 'help');
    Fs.exists(scriptsPath, function(exists) {
        let file, help, i, j, len, ref, helpRef, results;
        if (exists) {
            ref = Fs.readdirSync(scriptsPath);
            helpRef = Fs.readdirSync(helpPath);
            results = [];
            for (i = 0, len = ref.length; i < len; i++) {
                file = ref[i];
                results.push(robot.loadFile(scriptsPath, file));
            }
            for(j = 0; j < helpRef.length; j++){
                help = helpRef[j];
                results.push(robot.loadFile(helpPath, help));
            }
            return results;
        }
    });
};