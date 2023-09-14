"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.run = void 0;
const tl = require("azure-pipelines-task-lib/task");
const module_1 = require("./module");
function run() {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            var connectedServiceName = tl.getInput('PowerBIServiceEndpoint', true);
            var endpointUrl = tl.getEndpointUrl(connectedServiceName, true);
            var scheme = tl.getEndpointAuthorizationScheme(connectedServiceName, true);
            var isDebugEnabled = (process.env['SYSTEM_DEBUG'] || "").toLowerCase() === "true";
            var failOnStandardError = tl.getBoolInput('FailOnStandardError', false);
            var organizationType = tl.getEndpointDataParameter(connectedServiceName, 'OrganizationType', true);
            (0, module_1.logInfo)(`Endpoint URL: ${endpointUrl}`);
            (0, module_1.logInfo)(`Authentication scheme: ${scheme}`);
            (0, module_1.logInfo)(`Organization type: ${organizationType}`);
            if (scheme != "UsernamePassword") {
                var tenantId = tl.getEndpointAuthorizationParameter(connectedServiceName, 'TenantId', false);
                var clientId = tl.getEndpointAuthorizationParameter(connectedServiceName, 'ClientId', false);
                var clientSecret = tl.getEndpointAuthorizationParameter(connectedServiceName, 'ClientSecret', true);
                var clientCertificate = tl.getEndpointAuthorizationParameter(connectedServiceName, 'ClientCertificate', true);
                (0, module_1.logInfo)(`tenantId: ${tenantId}`);
                (0, module_1.logInfo)(`clientId: ${clientId}`);
                (0, module_1.logInfo)(`clientSecret: ${clientSecret}`);
                (0, module_1.logInfo)(`clientCertificate: ${clientCertificate}`);
            }
            else {
                var username = tl.getEndpointAuthorizationParameter(connectedServiceName, 'username', true);
                var password = tl.getEndpointAuthorizationParameter(connectedServiceName, 'password', true);
                (0, module_1.logInfo)(`username: ${username}`);
                (0, module_1.logInfo)(`password: ${password}`);
            }
            var action = tl.getInput('Action', true);
            (0, module_1.logInfo)(`Action: ${action}`);
            var crossWorkspaceRebinding = tl.getBoolInput('CrossWorkspaceRebinding', false);
            (0, module_1.logDebug)(`Cross Workspace Rebinding: ${crossWorkspaceRebinding}`);
            var skipReport = tl.getBoolInput('SkipReport', false);
            (0, module_1.logDebug)(`Skip Report: ${skipReport}`);
            var workspaceName = tl.getInput('WorkspaceName', false);
            (0, module_1.logDebug)(`Workspace: ${workspaceName}`);
            var reportWorkspaceName = tl.getInput('ReportWorkspaceName', false);
            (0, module_1.logDebug)(`Report Workspace: ${reportWorkspaceName}`);
            var capacityName = tl.getInput('CapacityName', false);
            (0, module_1.logDebug)(`Capacity name: ${capacityName}`);
            var powerbiPath = tl.getInput('PowerBIPath', false);
            (0, module_1.logDebug)(`Power BI Path: ${powerbiPath}`);
            var overwrite = tl.getBoolInput('Overwrite', false);
            (0, module_1.logDebug)(`Overwrite: ${overwrite}`);
            var create = tl.getBoolInput('Create', false);
            (0, module_1.logDebug)(`Create: ${create}`);
            var users = tl.getInput('Users', false);
            (0, module_1.logDebug)(`Users: ${users}`);
            var updateAll = tl.getBoolInput('UpdateAll', false);
            (0, module_1.logDebug)(`Update All: ${updateAll}`);
            var servicePrincipals = tl.getInput('ServicePrincipals', false);
            (0, module_1.logDebug)(`Report Workspace: ${servicePrincipals}`);
            var groupObjectIds = tl.getInput('GroupObjectIds', false);
            (0, module_1.logDebug)(`Group Object Ids: ${groupObjectIds}`);
            var scope = tl.getInput('Scope', false);
            (0, module_1.logDebug)(`Scope: ${scope}`);
            var permission = tl.getInput('Permission', false);
            (0, module_1.logDebug)(`Permission: ${permission}`);
            var datasetName = tl.getInput('DatasetName', false);
            (0, module_1.logDebug)(`Dataset name: ${datasetName}`);
            var reportName = tl.getInput('ReportName', false);
            (0, module_1.logDebug)(`Report name: ${reportName}`);
            var gatewayName = tl.getInput('GatewayName', false);
            (0, module_1.logDebug)(`Gateway name: ${gatewayName}`);
            var connectionString = tl.getInput('ConnectionString', false);
            (0, module_1.logDebug)(`Connectionstring: ${connectionString}`);
            var datasourceType = tl.getInput('DatasourceType', false);
            (0, module_1.logDebug)(`Datasource type: ${datasourceType}`);
            var newServer = tl.getInput('NewServer', false);
            (0, module_1.logDebug)(`New server: ${newServer}`);
            var oldServer = tl.getInput('OldServer', false);
            (0, module_1.logDebug)(`Old server: ${oldServer}`);
            var oldDatabase = tl.getInput('OldDatabase', false);
            (0, module_1.logDebug)(`Old database: ${oldDatabase}`);
            var newDatabase = tl.getInput('NewDatabase', false);
            (0, module_1.logDebug)(`New database: ${newDatabase}`);
            var oldUrl = tl.getInput('OldUrl', false);
            (0, module_1.logDebug)(`Old url: ${oldUrl}`);
            var newUrl = tl.getInput('NewUrl', false);
            (0, module_1.logDebug)(`New url: ${newUrl}`);
            var parameterInput = tl.getInput('ParameterInput', false);
            (0, module_1.logDebug)(`Report Workspace: ${parameterInput}`);
            var usernameInput = tl.getInput('Username', false);
            (0, module_1.logDebug)(`Username: ${usernameInput}`);
            var passwordInput = tl.getInput('Password', false);
            (0, module_1.logDebug)(`Password: ${passwordInput}`);
            var refreshScheduleInput = tl.getInput('RefreshScheduleInput', false);
            (0, module_1.logDebug)(`Refresh schedule: ${refreshScheduleInput}`);
            var tabularEditorArguments = tl.getInput('tabularEditorArguments', false);
            (0, module_1.logDebug)(`Tabular editor arguments: ${tabularEditorArguments}`);
            var principalType = tl.getInput('PrincipalType', false);
            (0, module_1.logDebug)(`Report Workspace: ${principalType}`);
            var datasetPermissionsUsers = tl.getInput('DatasetPermissionsUsers', false);
            (0, module_1.logDebug)(`Dataset permissions users: ${datasetPermissionsUsers}`);
            var datasetPermissionsGroupObjectIds = tl.getInput('DatasetPermissionsGroupObjectIds', false);
            (0, module_1.logDebug)(`Dataset permissions group object ids: ${datasetPermissionsGroupObjectIds}`);
            var datasetAccessRight = tl.getInput('DatasetAccessRight', false);
            (0, module_1.logDebug)(`Data access right: ${datasetAccessRight}`);
            var path = __dirname + "/run.ps1";
            let powershell = tl.tool(tl.which('pwsh') || tl.which('powershell') || tl.which('pwsh', true))
                .arg('-NoLogo')
                .arg('-NoProfile')
                .arg('-NonInteractive')
                .arg('-ExecutionPolicy')
                .arg('Unrestricted')
                .arg('-Command')
                .arg(`. '${path}'`);
            if (workspaceName) {
                powershell.arg("-WorkspaceName");
                powershell.arg(workspaceName);
            }
            powershell.arg("-EndpointUrl");
            powershell.arg(endpointUrl);
            if (action) {
                powershell.arg("-Action");
                powershell.arg(action);
            }
            if (powerbiPath) {
                powershell.arg("-FilePattern");
                powershell.arg(powerbiPath);
            }
            if (scheme) {
                powershell.arg("-Scheme");
                powershell.arg(scheme);
            }
            if (username) {
                powershell.arg("-Username");
                powershell.arg(username);
            }
            if (password) {
                powershell.arg("-PassWord");
                powershell.arg(password);
            }
            if (tenantId) {
                powershell.arg("-TenantId");
                powershell.arg(tenantId);
            }
            if (clientId) {
                powershell.arg("-ClientId");
                powershell.arg(clientId);
            }
            if (clientSecret) {
                powershell.arg("-ClientSecret");
                powershell.arg(clientSecret);
            }
            if (clientCertificate) {
                powershell.arg("-ClientCertificate");
                powershell.arg(clientCertificate);
            }
            if (organizationType) {
                powershell.arg("-OrganizationType");
                powershell.arg(organizationType);
            }
            if (overwrite) {
                powershell.arg("-Overwrite");
                powershell.arg(overwrite ? "1" : "0");
            }
            if (create) {
                powershell.arg("-Create");
                powershell.arg(create ? "1" : "0");
            }
            if (datasetName) {
                powershell.arg("-Dataset");
                powershell.arg(datasetName);
            }
            if (oldUrl) {
                powershell.arg("-OldUrl");
                powershell.arg(oldUrl);
            }
            if (newUrl) {
                powershell.arg("-NewUrl");
                powershell.arg(newUrl);
            }
            if (oldServer) {
                powershell.arg("-OldServer");
                powershell.arg(oldServer);
            }
            if (newServer) {
                powershell.arg("-NewServer");
                powershell.arg(newServer);
            }
            if (oldDatabase) {
                powershell.arg("-OldDatabase");
                powershell.arg(oldDatabase);
            }
            if (groupObjectIds) {
                powershell.arg("-GroupObjectIds");
                powershell.arg(groupObjectIds);
            }
            if (newDatabase) {
                powershell.arg("-NewDatabase");
                powershell.arg(newDatabase);
            }
            if (datasetAccessRight) {
                powershell.arg("-AccessRight");
                powershell.arg(datasetAccessRight);
            }
            if (datasetPermissionsUsers) {
                powershell.arg("-Users");
                powershell.arg(datasetPermissionsUsers);
            }
            if (datasourceType) {
                powershell.arg("-DatasourceType");
                powershell.arg(datasourceType);
            }
            if (updateAll) {
                powershell.arg("-UpdateAll");
                powershell.arg(updateAll ? "1" : "0");
            }
            if (skipReport) {
                powershell.arg("-SkipReport");
                powershell.arg(skipReport ? "1" : "0");
            }
            if (scope) {
                powershell.arg("-IndividualString");
                powershell.arg(scope);
            }
            if (servicePrincipals) {
                powershell.arg("-ServicePrincipalString");
                powershell.arg(servicePrincipals);
            }
            if (connectionString) {
                powershell.arg("-ConnectionString");
                powershell.arg(connectionString);
            }
            if (parameterInput) {
                powershell.arg("-ParameterInput");
                powershell.arg(parameterInput);
            }
            if (gatewayName) {
                powershell.arg("-GatewayName");
                powershell.arg(gatewayName);
            }
            if (reportName) {
                powershell.arg("-ReportName");
                powershell.arg(reportName);
            }
            if (capacityName) {
                powershell.arg("-CapacityName");
                powershell.arg(capacityName);
            }
            if (usernameInput) {
                powershell.arg("-InputUserName");
                powershell.arg(usernameInput);
            }
            if (passwordInput) {
                powershell.arg("-InputPassword");
                powershell.arg(passwordInput);
            }
            if (refreshScheduleInput) {
                powershell.arg("-RefreshScheduleInput");
                powershell.arg(refreshScheduleInput);
            }
            if (crossWorkspaceRebinding) {
                powershell.arg("-CrossWorkspaceRebinding");
                powershell.arg(crossWorkspaceRebinding ? "1" : "0");
            }
            if (reportWorkspaceName) {
                powershell.arg("-ReportWorkspaceName");
                powershell.arg(reportWorkspaceName);
            }
            if (reportName) {
                powershell.arg("-ReportName");
                powershell.arg(reportName);
            }
            if (tabularEditorArguments) {
                powershell.arg("-TabularEditorArguments");
                powershell.arg(tabularEditorArguments);
            }
            if (principalType) {
                powershell.arg("-PrincipalType");
                powershell.arg(principalType);
            }
            if (datasetPermissionsUsers) {
                powershell.arg("-DatasetPermissionsUsers");
                powershell.arg(datasetPermissionsUsers);
            }
            if (datasetPermissionsGroupObjectIds) {
                powershell.arg("-DatasetPermissionsGroupObjectIds");
                powershell.arg(datasetPermissionsGroupObjectIds);
            }
            if (datasetAccessRight) {
                powershell.arg("-DatasetAccessRight");
                powershell.arg(datasetAccessRight);
            }
            if (isDebugEnabled) {
                powershell.arg("-Verbose");
            }
            let options = {
                cwd: __dirname,
                failOnStdErr: true,
                errStream: process.stdout,
                outStream: process.stdout,
                ignoreReturnCode: true
            };
            // Listen for stderr.
            let stderrFailure = false;
            if (failOnStandardError) {
                powershell.on('stderr', (data) => {
                    stderrFailure = true;
                });
            }
            let exitCode = yield powershell.exec(options);
            if (exitCode !== 0) {
                tl.setResult(tl.TaskResult.Failed, tl.loc('JS_ExitCode', exitCode));
            }
            if (stderrFailure) {
                tl.setResult(tl.TaskResult.Failed, tl.loc('JS_Stderr'));
            }
        }
        catch (err) {
            let errorMessage = "Failed due to a specific error";
            if (err instanceof Error) {
                (0, module_1.logError)(err.message);
            }
        }
    });
}
exports.run = run;
run();
