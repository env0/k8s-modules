## Alternative Log Storage

By default, env0 stores the logs in a dedicated dynamodb table in env0 account. 
If you wish to have the logs be stored locally on your own cloud provider instead, we provide support for that for some cloud providers.

Currently, we support the following:

- AWS: DynamoDB table

When preparing for an agent installation, please prepare the log storage resources on your module, by applying the module with correct variables.
For more info, take a look at each individual module's README