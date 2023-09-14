import tl = require("azure-pipelines-task-lib/task");
import tr = require('azure-pipelines-task-lib/toolrunner');

import {
    logInfo,
    logError,
    logDebug
} from "./module";

export async function run() {
    try {
        var connectedServiceName = tl.getInput('PowerBIServiceEndpoint', true) as string;
        var endpointUrl = tl.getEndpointUrl(connectedServiceName, true) as string;
        var scheme = tl.getEndpointAuthorizationScheme(connectedServiceName, true);
        var isDebugEnabled = (process.env['SYSTEM_DEBUG'] || "").toLowerCase() === "true";
        var failOnStandardError = tl.getBoolInput('FailOnStandardError', false);
        var organizationType = tl.getEndpointDataParameter(connectedServiceName, 'OrganizationType', true);

        logInfo(`Endpoint URL: ${endpointUrl}`);
        logInfo(`Authentication scheme: ${scheme}`);
        logInfo(`Organization type: ${organizationType}`);

        if (scheme != "UsernamePassword") {
            var tenantId = tl.getEndpointAuthorizationParameter(connectedServiceName, 'TenantId', false);
            var clientId = tl.getEndpointAuthorizationParameter(connectedServiceName, 'ClientId', false);
            var clientSecret = tl.getEndpointAuthorizationParameter(connectedServiceName, 'ClientSecret', true);
            var clientCertificate = tl.getEndpointAuthorizationParameter(connectedServiceName, 'ClientCertificate', true);
            logInfo(`tenantId: ${tenantId}`);
            logInfo(`clientId: ${clientId}`);
            logInfo(`clientSecret: ${clientSecret}`);
            logInfo(`clientCertificate: ${clientCertificate}`);
        } else {
            var username = tl.getEndpointAuthorizationParameter(connectedServiceName, 'username', true);
            var password = tl.getEndpointAuthorizationParameter(connectedServiceName, 'password', true);
            logInfo(`username: ${username}`);
            logInfo(`password: ${password}`);
        }

        var action = tl.getInput('Action', true) as string;
        logInfo(`Action: ${action}`);

        var crossWorkspaceRebinding = tl.getBoolInput('CrossWorkspaceRebinding', false);
        logDebug(`Cross Workspace Rebinding: ${crossWorkspaceRebinding}`);

        var skipReport = tl.getBoolInput('SkipReport', false);
        logDebug(`Skip Report: ${skipReport}`);

        var workspaceName = tl.getInput('WorkspaceName', false) as string;
        logDebug(`Workspace: ${workspaceName}`);

        var reportWorkspaceName = tl.getInput('ReportWorkspaceName', false) as string;
        logDebug(`Report Workspace: ${reportWorkspaceName}`);

        var capacityName = tl.getInput('CapacityName', false) as string;
        logDebug(`Capacity name: ${capacityName}`);

        var powerbiPath = tl.getInput('PowerBIPath', false) as string;
        logDebug(`Power BI Path: ${powerbiPath}`);

        var overwrite = tl.getBoolInput('Overwrite', false);
        logDebug(`Overwrite: ${overwrite}`);

        var create = tl.getBoolInput('Create', false);
        logDebug(`Create: ${create}`);

        var users = tl.getInput('Users', false) as string;
        logDebug(`Users: ${users}`);

        var updateAll = tl.getBoolInput('UpdateAll', false);
        logDebug(`Update All: ${updateAll}`);

        var servicePrincipals = tl.getInput('ServicePrincipals', false) as string;
        logDebug(`Report Workspace: ${servicePrincipals}`);

        var groupObjectIds = tl.getInput('GroupObjectIds', false) as string;
        logDebug(`Group Object Ids: ${groupObjectIds}`);

        var scope = tl.getInput('Scope', false) as string;
        logDebug(`Scope: ${scope}`);

        var permission = tl.getInput('Permission', false) as string;
        logDebug(`Permission: ${permission}`);

        var datasetName = tl.getInput('DatasetName', false) as string;
        logDebug(`Dataset name: ${datasetName}`);

        var reportName = tl.getInput('ReportName', false) as string;
        logDebug(`Report name: ${reportName}`);

        var gatewayName = tl.getInput('GatewayName', false) as string;
        logDebug(`Gateway name: ${gatewayName}`);

        var connectionString = tl.getInput('ConnectionString', false) as string;
        logDebug(`Connectionstring: ${connectionString}`);

        var datasourceType = tl.getInput('DatasourceType', false) as string;
        logDebug(`Datasource type: ${datasourceType}`);

        var newServer = tl.getInput('NewServer', false) as string;
        logDebug(`New server: ${newServer}`);

        var oldServer = tl.getInput('OldServer', false) as string;
        logDebug(`Old server: ${oldServer}`);

        var oldDatabase = tl.getInput('OldDatabase', false) as string;
        logDebug(`Old database: ${oldDatabase}`);

        var newDatabase = tl.getInput('NewDatabase', false) as string;
        logDebug(`New database: ${newDatabase}`);

        var oldUrl = tl.getInput('OldUrl', false) as string;
        logDebug(`Old url: ${oldUrl}`);

        var newUrl = tl.getInput('NewUrl', false) as string;
        logDebug(`New url: ${newUrl}`);

        var parameterInput = tl.getInput('ParameterInput', false) as string;
        logDebug(`Report Workspace: ${parameterInput}`);

        var usernameInput = tl.getInput('Username', false) as string;
        logDebug(`Username: ${usernameInput}`);

        var passwordInput = tl.getInput('Password', false) as string;
        logDebug(`Password: ${passwordInput}`);

        var refreshScheduleInput = tl.getInput('RefreshScheduleInput', false) as string;
        logDebug(`Refresh schedule: ${refreshScheduleInput}`);

        var tabularEditorArguments = tl.getInput('tabularEditorArguments', false) as string;
        logDebug(`Tabular editor arguments: ${tabularEditorArguments}`);

        var principalType = tl.getInput('PrincipalType', false) as string;
        logDebug(`Report Workspace: ${principalType}`);

        var datasetPermissionsUsers = tl.getInput('DatasetPermissionsUsers', false) as string;
        logDebug(`Dataset permissions users: ${datasetPermissionsUsers}`);

        var datasetPermissionsGroupObjectIds = tl.getInput('DatasetPermissionsGroupObjectIds', false) as string;
        logDebug(`Dataset permissions group object ids: ${datasetPermissionsGroupObjectIds}`);

        var datasetAccessRight = tl.getInput('DatasetAccessRight', false) as string;
        logDebug(`Data access right: ${datasetAccessRight}`);

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

        let options = <tr.IExecOptions>{
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

        let exitCode: number = await powershell.exec(options);
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
            logError(err.message);
        }
    }
}

run();