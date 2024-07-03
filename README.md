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

### Add dagger to current project

```
dagger init --sdk=github.com/dragoonis/dagger/sdk/php@add-php-runtime .
```

### Make sure it all works - check the available dagger functions
```
dagger functions
```

You will see
```
Name       Description
echo       Echo the value to standard output
grep-dir   Search a directory for lines matching a pattern
```

### Check out the locally generated Dagger PHP Module
```
./dagger/src/DaggerLaravelApp.php
```

### 
``` php
#[DaggerFunction('Echo the value to standard output')]
public function echo(
    #[DaggerArgument('The value to echo')]
    string $value = 'hello world',
): Container {
    return $this->client->container()
        ->from('alpine:latest')
        ->withExec(['echo', $value]);
}

```

### Call the echo function
```
dagger call echo --value="HEYYYYYYY" output
```

### Change the function to return a string
``` php
#[DaggerFunction('Echo the value to standard output')]
public function echo(
    #[DaggerArgument('The value to echo')]
    string $value = 'hello world',
): string {
    return $this->client->container()
        ->from('alpine:latest')
        ->withExec(['echo', $value])
        ->stdout();
}
```

### Rebuild the function definition
```
dagger develop && dagger functions
```

```
Name       Description
echo       Echo the value to standard output
grep-dir   Search a directory for lines matching a pattern
```

### Call it, without any stdout, as it's in the code now

```
dagger call echo --value="HEYYYYYYY"
```

## When mounting code directories, add to exclude file, in dagger.json, but can also exlude from dagger paramteter

dagger.json
``` json
  "exclude": [
    "**/vendor"
  ],
```


## Mounting your codebase directories into dagger

```
dagger call grep-dir --directory=. --pattern=Trust
```

``` php
    #[DaggerFunction('Search a directory for lines matching a pattern')]
     public function grepDir(
         #[DaggerArgument('The directory to search')]
         Directory $directory,
         #[DaggerArgument('The pattern to search for')]
         string $pattern
    ): string {
         return $this->client->container()->from('alpine:latest')
             ->withMountedDirectory('/mnt', $directory)
             ->withWorkdir('/mnt')
             ->withExec(["grep", '-R', $pattern, '.'])
             ->stdout();
     }
```

### TERMINAL MODE!!!

Add this to your file

``` php

```

### Bring in the new definitions
```
dagger develop && dagger functions
```



## taking a PHP image that doesn't have compose binary in it, and do a FROM and then run a composer install --dev

### docker build from existing dockerfile (current webapp)

### dagger install the mysql module, and then run dagger develop

### take the setup.sh tasks, or the docker-compose exec tasks and move them to ->withExec()

### maybe make this a base() function

### call it from caller call integration-tests

### show on dagger cloud