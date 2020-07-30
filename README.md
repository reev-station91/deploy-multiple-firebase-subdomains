# Deploy Multiple Subdomains to Firebase

A GitHub Action to deploy to Firebase Hosting. I have designed this fork specifically with Cloud Run and subdomain
routing in mind.

- You can choose a specific branch to allow deployment by using the `TARGET_BRANCH` env var (`master` if not specified).
- Make sure you have the `firebase.json` file in the respective subdirectory. Use `.` for `FIREBASE_PROJECT_PATH` env
variable if you don't need to use subdirectories.
- Get the Firebase token by running `firebase login:ci` and
[store it](https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets)
as the `FIREBASE_TOKEN` secret.
- Set the project name in the `FIREBASE_PROJECT` env var.

## Sub-directory/Subdomain support
The original repository is awesome, but it didn't support having subfolders.

Use `$FIREBASE_PROJECT_PATH` environment variable to configure path to firebase project directory. The action will go
into the `$FIREBASE_PROJECT_PATH` before executing `firebase deploy`.

This feature is handy if you're using a single repository to manage your routing for multiple subdomains. For example,
you could have a subdirectory for every subdomain.

```
|--root
|   |-- api
|   |   |-- .firebaserc
|   |   |-- firebase.json
|   |-- www
|   |   |-- .firebaserc
|   |   |-- firebase.json
|   |-- store
|   |   |-- .firebaserc
|   |   |-- firebase.json
```

## Setting up your subdomains
1. To setup routing rules **independent of each subdomain**, you will need to create a new project in Google Cloud
Platform (GCP) or Firebase.
2. Go to `https://console.firebase.google.com/u/0/project/<GCP_PROJECT_ID_A>/hosting/main`.
3. Under the `<GCP_PROJECT_ID_A> domains` section, click `Add custom domain`.
4. Follow the steps to add your custom domain.
5. Then configure the `FIREBASE_PROJECT` environment variable in your workflow to point to the relevant project you would
like to deploy the hosting rules to.

This will deploy only the relevant hosting rules to that project and if you've configured one subdomain per project,
that will work out well 😁

## Getting your Firebase Project ID
Visit the [projects page](https://console.firebase.google.com/u/0/project/) and then underneath the project name in the
project card, you should see the project id.

## Common Errors
### Cloud Run
#### Google Cloud API Not Enabled
The Cloud Run Admin API needs to be enabled. Just go to the link in the build output. It will bring you to a page to
enable that api. You just need to click on the enable button if you have permissions to do so. It requires billing to be
enabled.

#### Cloud Run Service doesn't exist in this region in this project
The Cloud Run service needs to exist in the same project as the firebase hosting rules. Rule of thumb is one project
per subdomain. So just make sure you redeploy your Cloud Run service to the appropriate project using the
`--region ${REGION}` flag when you run `gcloud run deploy`.

## Example Workflow
This is an example for a firebase hosting project that is purely a router for Cloud Run.

**api/firebase.json**
```json
{
  "hosting": {
    "public": "public",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites":  [
      {
        "source": "/development/service-a{,/**}",
        "run": {
          "serviceId": "development-service-a",
          "region": "us-central1"
        }
      },
      {
        "source": "/staging/service-b{,/**}",
        "run": {
          "serviceId": "staging-service-b",
          "region": "us-central1"
        }
      },
      {
        "source": "/staging/service-c{,/**}",
        "run": {
          "serviceId": "staging-service-c",
          "region": "us-central1"
        }
      }
    ]
  }
}
```

**.github/workflows/deploy-api.yml**
```yaml
name: Build and Deploy Api
on:
  push:
    branches:
      - master
    paths:
      - .github/workflows/deploy-api.yml
      - api/**
jobs:
  api:
    name: Build and Deploy Api
    runs-on: ubuntu-latest
    steps:
    - name: Check out code
      uses: actions/checkout@master
    - name: Deploy to Firebase
      uses: lowply/deploy-firebase@v0.0.3
      env:
        FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
        FIREBASE_PROJECT: <FIREBASE_PROJECT_ID>
        TARGET_BRANCH: master
        FIREBASE_PROJECT_PATH: api
```

If you want to combine them into a single workflow you can do that as well. **.github/workflows/deploy.yml**
The jobs will still run in parallel to make things quicker.
```yaml
name: Build and Deploy Merch Store
on:
  push:
    branches:
      - master
    paths:
      - .github/workflows/deploy-api.yml
      - store/**
jobs:
  store:
    name: Build and Deploy Api
    runs-on: ubuntu-latest
    steps:
    - name: Check out code
      uses: actions/checkout@master
    - name: Deploy to Firebase
      uses: lowply/deploy-firebase@v0.0.3
      env:
        FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
        FIREBASE_PROJECT: <GCP_PROJECT_ID_C>
        TARGET_BRANCH: master
        FIREBASE_PROJECT_PATH: store
  www:
    name: Build and Deploy Api
    runs-on: ubuntu-latest
    steps:
    - name: Check out code
      uses: actions/checkout@master
    - name: Deploy to Firebase
      uses: lowply/deploy-firebase@v0.0.3
      env:
        FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
        FIREBASE_PROJECT: <GCP_PROJECT_ID_B>
        TARGET_BRANCH: master
        FIREBASE_PROJECT_PATH: www
```
