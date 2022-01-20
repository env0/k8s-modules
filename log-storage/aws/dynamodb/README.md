## DynamoDB table on your own cloud provider

You can apply this module on your AWS account, to create a DynamoDB table for storing logs. env0 will assume the role created in this module, in order to read and write logs

#### Variables:

- region - AWS region in which the dynamodb will be created. Should be provided to env0 as well
- external_id - An external ID provided by env0 for assuming the roles to read and write from and to log table
- agent_key - A unique key for this remote agent provided by env0
