# cloud-cron
A quick application of AWS Copilot to sync Lichess and Beeminder.

## Setup
### Install prerequisites. 
1. [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and set it up with your credentials.
2. [Install Docker Desktop](https://docs.docker.com/get-docker/).
3. [Install AWS Copilot](https://github.com/aws/copilot-cli#installation). 
```
brew install aws/tap/copilot-cli
```

### Deploy with Copilot
Create the application and environment (high-level logical grouping) that your jobs will live in. This will take a couple of minutes.
```bash
copilot app init cloud
copilot env init --name cron --profile default --default-config
```


Populate [secrets](https://aws.github.io/copilot-cli/docs/commands/secret-init/) for the app. Run the following commands:
```bash
copilot secret init --name BEEMINDER_USERNAME
copilot secret init --name BEEMINDER_API_TOKEN
copilot secret init --name LICHESS_USERNAME
```
You'll be prompted to enter the values of each of these secrets. Paste them into the terminal and hit enter each time.

Modify local manifest if necessary. If your goal name is not "chess," You'll need to change the goal name in the [`variables`](https://aws.github.io/copilot-cli/docs/developing/environment-variables/#how-do-i-add-my-own-environment-variables) section to whatever your Beeminder goal's name is. 

Initialize and deploy the job. This command will run the job at the 55th minute of every hour. You can modify the schedule by changing the `schedule` field in the generated manifest at `copilot/beeminder-chess/manifest.yml`.
```bash
copilot init \
  --name beeminder \
  --type Scheduled\ Job \
  --dockerfile Dockerfile \
  --schedule "55 * * * *" \
  --retries 2
```

```bash
copilot deploy
```
## Pricing
This should't be expensive. The only resources you'll incur a charge for are the containers themselves, and they're billed by the second at about $7.50/month. The total charge for the ECR docker image storage + execution costs should be about 5 cents per month.
