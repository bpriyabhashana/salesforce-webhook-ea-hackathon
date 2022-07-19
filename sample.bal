import ballerinax/trigger.salesforce;
import ballerina/log;
import ballerina/http;
import ballerina/io;

configurable string & readonly username = ?;
configurable string & readonly password = ?;
configurable string WEBHOOK_URL = ?;
configurable string WEBHOOK_USER_NAME = ?;
configurable string WEBHOOK_PASSWORD = ?;

salesforce:ListenerConfig config = {
    username,
    password,
    channelName: "/data/ChangeEvents",
    environment: "Sandbox"
};

listener salesforce:Listener webhookListener = new (config);

service salesforce:RecordService on webhookListener {

    remote function onCreate(salesforce:EventData payload) returns error? {
       return;
    }
    remote function onUpdate(salesforce:EventData payload) returns error? {
        json record_id = payload?.metadata?.recordId;
        string param = record_id.toString();
        string url = WEBHOOK_URL + "?account_id=" + param;

        http:Client securedEP = check new (url,
            auth = {
            username: WEBHOOK_USER_NAME,
            password: WEBHOOK_PASSWORD
        });
        json|error response = check securedEP->get("");
        io:println(payload);
        if (response is json) {
            log:printInfo("Webhook triggered successfully", id = record_id);
            return;
        } else {
            log:printError("Error occurred when calling the webhook", id = record_id);
        }

    }
    remote function onDelete(salesforce:EventData payload) returns error? {
        return;
    }
    remote function onRestore(salesforce:EventData payload) returns error? {
        return;
    }
}

