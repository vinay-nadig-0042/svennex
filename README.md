# Svennex

Open source & self hostable alternative to [Dockerhub Automated Builds](https://docs.docker.com/docker-hub/builds/). Svennex aims to support all major code repositories(Github, Gitlab etc) and all major docker registries(DockerHub, AWS ECR, GCR, Gitlab Registry etc).

**Note:** Svennex is still in **alpha** stage of development. There might be breaking changes in the future.

### Deployment

One click deploy to AWS with Cloudformation.

**Note:** This template is built for **convenience & speed** rather than security. A production ready template is in the pipeline. 

It deploys the following components.

1. VPC
2. Subnets - Private & Public
3. NAT Gateway
4. RDS Instance
5. Elasticache Redis Instance
6. EC2 Instance

| Region Code    | Region Name               | Deploy |
| -------------- | ------------------------- | ------ |
| us-east-2      | US East (Ohio)            |        |
| us-east-1      | US East (N. Virginia)     |        |
| us-west-1      | US West (N. California)   |        |
| us-west-2      | US West (Oregon)          |        |
| af-south-1     | Africa (Cape Town)        |        |
| ap-east-1      | Asia Pacific (Hong Kong)  |        |
| ap-south-1     | Asia Pacific (Mumbai)     |        |
| ap-northeast-3 | Asia Pacific (Osaka)      |        |
| ap-northeast-2 | Asia Pacific (Seoul)      |        |
| ap-southeast-1 | Asia Pacific (Singapore)  |        |
| ap-southeast-2 | Asia Pacific (Sydney)     |        |
| ap-northeast-1 | Asia Pacific (Tokyo)      |        |
| ca-central-1   | Canada (Central)          |        |
| eu-central-1   | Europe (Frankfurt)        |        |
| eu-west-1      | Europe (Ireland)          |        |
| eu-west-2      | Europe (London)           |        |
| eu-south-1     | Europe (Milan)            |        |
| eu-west-3      | Europe (Paris)            |        |
| eu-north-1     | Europe (Stockholm)        |        |
| me-south-1     | Middle East (Bahrain)     |        |
| sa-east-1      | South America (São Paulo) |        |

### Getting Started

You will need the following components ready before deploying Svennex.

1. **Github OAuth Application**: A Github OAuth Application that will allow Svennex to access Github Repositories. Follow instructions [here](https://docs.github.com/en/developers/apps/building-oauth-apps/creating-an-oauth-app) to create one and copy the Client ID & Client Secret. Provide `https://<FQDN>/oauth/github/callback` as the callback url where FQDN is the domain name where you will access Svennex.
2. **Gitlab OAuth Application**: A Gitlab OAuth Application that will allow Svennex to access Gitlab Repositories. Follow instructions [here](https://docs.gitlab.com/ee/integration/oauth_provider.html) to create one an copy the Client ID & Client secret. Provide `https://<FQDN>/oauth/gitlab/callback` as the callback url where FQDN is the domain name where you will access Svennex.
3. **SSH Key**: Create or Import a Key Pair into the AWS account in the region where you are deploying Svennex.
4. **FQDN**: You will need a domain name to point to Svennex once it's deployed. You can either use a subdomain or a root domain. Once you have deployed Svennex, you will have to update the DNS record to point to the EC2 Instance's IP address.
5. **SMTP Config**: You will need a SMTP interface to send transactional emails(Sign Up confirmation, Password Reset etc). You can either use SendGrid/AWS SES for this. Copy the username, password, SMTP domain, SMTP Address & Port. Sendgrid's free tier works nicely and you can find the documenation [here](https://docs.sendgrid.com/for-developers/sending-email/rubyonrails)

