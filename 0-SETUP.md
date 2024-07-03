# Preparation - Setting up the 

@todo - put these workshop details inside the dagger-laravel-app repo, so we can be in that context, and type "dagger init" on it.

## Step 0 - Check your system

You will need
- docker
- docker-compose
- make

```
./test-prerequisites.sh
```

## Step 1 - Forking the laravel docker app, on github

Fork it https://github.com/dragoonis/dagger-laravel-app/fork

Clone your own fork, locally, side by side with this `dagger-workshop-websummit` repository

```
git clone <my repo> dagger-laravel-app

cd dagger-laravel-app
```

## Step 2 - Install the laravel docker app, locally

```
make setup
```

### Run the unit tests
@todo - built some unit tests - just grab some classes, and some unit tests of those classes from another project
```
make unit
```

### Run the integration tests

```
make test
```

## SUCCESS!

You now have a working docker-based laravel app working, with a MariaDB/MySQL database connected.

## Step 4 - Install Dagger

### Install dagger version 0.11.9

```
./install-dagger.sh
```

### Test Dagger is operational
```
./test-dagger.sh
```

### Log into Dagger Cloud

Run the below command, authenticate using github. Keep the tab open
```
dagger login
```