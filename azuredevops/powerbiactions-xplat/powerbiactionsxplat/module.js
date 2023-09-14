"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.writeVariable = exports.logError = exports.logInfo = exports.logWarning = exports.logDebug = void 0;
const tl = require("azure-pipelines-task-lib/task");
// moving the logging function to a separate file
function logDebug(msg) {
    tl.debug(msg);
}
exports.logDebug = logDebug;
function logWarning(msg) {
    tl.warning(msg);
}
exports.logWarning = logWarning;
function logInfo(msg) {
    console.log(msg);
}
exports.logInfo = logInfo;
function logError(msg) {
    tl.error(msg);
    tl.setResult(tl.TaskResult.Failed, msg);
}
exports.logError = logError;
function writeVariable(variableName, value) {
    if (variableName) {
        logInfo(`Writing output variable ${variableName}`);
        // the newlines cause a problem only first line shown
        // so remove them
        var newlineRemoved = value.replace(/\n/gi, "`n");
        tl.setVariable(variableName, newlineRemoved);
    }
}
exports.writeVariable = writeVariable;
