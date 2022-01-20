## DynamoDB table on your own cloud provider

You can apply this module on your AWS account, to create a DynamoDB table for storing logs. env0 will assume the role created in this module, in order to read and write logs.
When using this module, make sure the `aws` provider is using the correct region

#### Variables:

- external_id - An external ID provided by env0 for assuming the roles to read and write from and to log table
- agent_key - A unique key for this remote agent provided by env0
