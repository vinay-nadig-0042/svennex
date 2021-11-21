# Svennex

Open source & self hostable alternative to [Dockerhub Automated Builds](https://docs.docker.com/docker-hub/builds/). Svennex aims to support all major code repositories(Github, Gitlab etc) and all major docker registries(DockerHub, AWS ECR, GCR, Gitlab Registry etc).

**Note:** Svennex is still in **alpha** stage of development. There might be breaking changes in the future.

### Getting Started

You will need the following components ready before deploying Svennex.

1. **Github OAuth Application**: A Github OAuth Application that will allow Svennex to access Github Repositories. Follow instructions [here](https://docs.github.com/en/developers/apps/building-oauth-apps/creating-an-oauth-app) to create one and copy the Client ID & Client Secret. Provide `https://<FQDN>/oauth/github/callback` as the callback url where FQDN is the domain name where you will access Svennex.
2. **Gitlab OAuth Application**: A Gitlab OAuth Application that will allow Svennex to access Gitlab Repositories. Follow instructions [here](https://docs.gitlab.com/ee/integration/oauth_provider.html) to create one an copy the Client ID & Client secret. Provide `https://<FQDN>/oauth/gitlab/callback` as the callback url where FQDN is the domain name where you will access Svennex.
3. **SSH Key**: Create or Import a Key Pair into the AWS account in the region where you are deploying Svennex.
4. **FQDN**: You will need a domain name to point to Svennex once it's deployed. You can either use a subdomain or a root domain. Once you have deployed Svennex, you will have to update the DNS record to point to the EC2 Instance's IP address.
5. **SMTP Config**: You will need a SMTP interface to send transactional emails(Sign Up confirmation, Password Reset etc). You can either use SendGrid/AWS SES for this. Copy the username, password, SMTP domain, SMTP Address & Port. Sendgrid's free tier works nicely and you can find the documenation [here](https://docs.sendgrid.com/for-developers/sending-email/rubyonrails)

Once you have these components ready, you can move on to the deployment.

### Deployment

One click deploy to AWS with Cloudformation.

**Note:** This template is built for **convenience & speed** rather than security. A production ready template is in the pipeline. 

It deploys the following components.

1. VPC
2. 2 Public Subnets
3. NAT Gateway
4. RDS Instance
5. Elasticache Redis Instance
6. EC2 Instance

| Region Code    | Region Name               | Deploy                                                       |
| -------------- | ------------------------- | ------------------------------------------------------------ |
| us-east-2      | US East (Ohio)            | [Deploy To AWS](https://us-east-2.console.aws.amazon.com/cloudformation/home?region=us-east-2#/stacks/create/) |
| us-east-1      | US East (N. Virginia)     | [Deploy To AWS](https://us-east-1.console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/create/review?templateURL=https://svennex-cf-templates.s3.amazonaws.com/app.yml&stackName=Svennex) |
| us-west-1      | US West (N. California)   | [Deploy To AWS](https://us-west-1.console.aws.amazon.com/cloudformation/home?region=us-west-1#/stacks/create/review?templateURL=https://svennex-cf-templates.s3.amazonaws.com/app.yml&stackName=Svennex) |
| us-west-2      | US West (Oregon)          | [Deploy To AWS](https://us-west-2.console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/create/review?templateURL=https://svennex-cf-templates.s3.amazonaws.com/app.yml&stackName=Svennex) |
| af-south-1     | Africa (Cape Town)        | [Deploy To AWS](https://af-south-1.console.aws.amazon.com/cloudformation/home?region=af-south-1#/stacks/create/review?templateURL=https://svennex-cf-templates.s3.amazonaws.com/app.yml&stackName=Svennex) |
| ap-east-1      | Asia Pacific (Hong Kong)  | [Deploy To AWS](https://ap-east-1.console.aws.amazon.com/cloudformation/home?region=ap-east-1#/stacks/create/review?templateURL=https://svennex-cf-templates.s3.amazonaws.com/app.yml&stackName=Svennex) |
| ap-south-1     | Asia Pacific (Mumbai)     | [Deploy To AWS](https://ap-south-1.console.aws.amazon.com/cloudformation/home?region=ap-south-1#/stacks/create/review?templateURL=https://svennex-cf-templates.s3.amazonaws.com/app.yml&stackName=Svennex) |
| ap-northeast-3 | Asia Pacific (Osaka)      | [Deploy To AWS](https://ap-northeast-3.console.aws.amazon.com/cloudformation/home?region=ap-northeast-3#/stacks/create/review?templateURL=https://svennex-cf-templates.s3.amazonaws.com/app.yml&stackName=Svennex) |
| ap-northeast-2 | Asia Pacific (Seoul)      | [Deploy To AWS](https://ap-northeast-2.console.aws.amazon.com/cloudformation/home?region=ap-northeast-2#/stacks/create/review?templateURL=https://svennex-cf-templates.s3.amazonaws.com/app.yml&stackName=Svennex) |
| ap-southeast-1 | Asia Pacific (Singapore)  | [Deploy To AWS](https://ap-southeast-1.console.aws.amazon.com/cloudformation/home?region=ap-southeast-1#/stacks/create/review?templateURL=https://svennex-cf-templates.s3.amazonaws.com/app.yml&stackName=Svennex) |
| ap-southeast-2 | Asia Pacific (Sydney)     | [Deploy To AWS](https://ap-southeast-2.console.aws.amazon.com/cloudformation/home?region=ap-southeast-2#/stacks/create/review?templateURL=https://svennex-cf-templates.s3.amazonaws.com/app.yml&stackName=Svennex) |
| ap-northeast-1 | Asia Pacific (Tokyo)      | [Deploy To AWS](https://ap-northeast-1.console.aws.amazon.com/cloudformation/home?region=ap-northeast-1#/stacks/create/review?templateURL=https://svennex-cf-templates.s3.amazonaws.com/app.yml&stackName=Svennex) |
| ca-central-1   | Canada (Central)          | [Deploy To AWS](https://ca-central-1.console.aws.amazon.com/cloudformation/home?region=ca-central-1#/stacks/create/review?templateURL=https://svennex-cf-templates.s3.amazonaws.com/app.yml&stackName=Svennex) |
| eu-central-1   | Europe (Frankfurt)        | [Deploy To AWS](https://eu-central-1.console.aws.amazon.com/cloudformation/home?region=eu-central-1#/stacks/create/review?templateURL=https://svennex-cf-templates.s3.amazonaws.com/app.yml&stackName=Svennex) |
| eu-west-1      | Europe (Ireland)          | [Deploy To AWS](https://eu-west-1.console.aws.amazon.com/cloudformation/home?region=eu-west-1#/stacks/create/review?templateURL=https://svennex-cf-templates.s3.amazonaws.com/app.yml&stackName=Svennex) |
| eu-west-2      | Europe (London)           | [Deploy To AWS](https://eu-west-2.console.aws.amazon.com/cloudformation/home?region=eu-west-2#/stacks/create/review?templateURL=https://svennex-cf-templates.s3.amazonaws.com/app.yml&stackName=Svennex) |
| eu-south-1     | Europe (Milan)            | [Deploy To AWS](https://eu-south-1.console.aws.amazon.com/cloudformation/home?region=eu-south-1#/stacks/create/review?templateURL=https://svennex-cf-templates.s3.amazonaws.com/app.yml&stackName=Svennex) |
| eu-west-3      | Europe (Paris)            | [Deploy To AWS](https://eu-west-3.console.aws.amazon.com/cloudformation/home?region=eu-west-3#/stacks/create/review?templateURL=https://svennex-cf-templates.s3.amazonaws.com/app.yml&stackName=Svennex) |
| eu-north-1     | Europe (Stockholm)        | [Deploy To AWS](https://eu-north-1.console.aws.amazon.com/cloudformation/home?region=eu-north-1#/stacks/create/review?templateURL=https://svennex-cf-templates.s3.amazonaws.com/app.yml&stackName=Svennex) |
| me-south-1     | Middle East (Bahrain)     | [Deploy To AWS](https://me-south-1.console.aws.amazon.com/cloudformation/home?region=me-south-1#/stacks/create/review?templateURL=https://svennex-cf-templates.s3.amazonaws.com/app.yml&stackName=Svennex) |
| sa-east-1      | South America (São Paulo) | [Deploy To AWS](https://sa-east-1.console.aws.amazon.com/cloudformation/home?region=sa-east-1#/stacks/create/review?templateURL=https://svennex-cf-templates.s3.amazonaws.com/app.yml&stackName=Svennex) |

