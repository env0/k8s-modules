## DynamoDB table on your own cloud provider

You can apply this module on your AWS account, to create DynamoDB tables for storing logs. env0 will assume the role created in this module, in order to read and write logs.
When using this module, make sure the `aws` provider is using the correct region

#### Variables:

- external_id - An external ID provided by env0 for assuming the roles to read and write from and to log table
- agent_key - A unique key for this remote agent provided by env0

See [this example](https://search.opentofu.org/provider/env0/env0/latest/docs/resources/agent_pool#example-usage:~:text=%23%20Hosting%20deployment%20logs%20in%20your%20AWS%20account) for configuration that combine env0 provider and this module to configure the agent and create required infrastructure. 