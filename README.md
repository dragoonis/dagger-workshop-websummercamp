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

### Add dagger to current project

```
@todo - dagger init - use paul's fork for dagger --sdk
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
