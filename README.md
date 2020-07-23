# Deploy to Firebase

A GitHub Action to deploy to Firebase Hosting. I have designed this fork specifically with Cloud Run and subdomain
routing in mind.

- You can choose a specific branch to allow deployment by using the `TARGET_BRANCH` env var (`master` if not specified).
- Make sure you have the `firebase.json` file in the respective subdirectory. Use `.` for `FIREBASE_PROJECT_PATH` env
variable if you don't need to use subdirectories.
- Get the Firebase token by running `firebase login:ci` and [store it](https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets) as the `FIREBASE_TOKEN` secret
- Set the project name in the `FIREBASE_PROJECT` env var

## Sub-directory support
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
        FIREBASE_PROJECT: <GCP_PROJECT_ID>
        TARGET_BRANCH: main
        FIREBASE_PROJECT_PATH: api
```

**.github/workflows/deploy-www.yml**
```yaml
name: Build and Deploy Marketing Site
on:
  push:
    branches:
      - master
    paths:
      - .github/workflows/deploy-api.yml
      - www/**
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
        FIREBASE_PROJECT: <GCP_PROJECT_ID>
        TARGET_BRANCH: main
        FIREBASE_PROJECT_PATH: www
```

**.github/workflows/deploy-store.yml**
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
        FIREBASE_PROJECT: <GCP_PROJECT_ID>
        TARGET_BRANCH: main
        FIREBASE_PROJECT_PATH: store
```
