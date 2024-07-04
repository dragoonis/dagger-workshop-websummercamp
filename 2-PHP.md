
# NEW FILE

## PHP Environments

``` php
    #[DaggerFunction('php-base')]
    public function phpBase(): Container {
       return $this->client->container()
           ->from('php:8.3-cli-alpine')
           ->withWorkdir('/tmp/app');
    }

    #[DaggerFunction('php-version')]
    public function phpVersion(
    ): string {
       return $this->phpBase()
           ->withExec($this->cmd('php -v'))
           ->stdout();
    }

    #[DaggerFunction('php-terminal')]
    public function phpTerminal(
    ): Terminal {
       return $this->phpBase()
           ->terminal();
    }
```

``` 
dagger develop && dagger functions
```

```
dagger call php-version
```

```
dagger call php-terminal
```

### CLI arg on top of a Container
```
dagger call php-base terminal
```



## docker build from existing Dockerfile (current webapp)
``` php
    #[DaggerFunction('laravel-app-build')]
    public function laravelAppBuild(
        #[DaggerArgument('The source code directory')]
        Directory $source,
    ): Container {

       return $this->client->container()
           ->build($source);
    }
```

```
dagger develop && dagger functions
```

```
dagger call laravel-app-build --source=. terminal
```

Then run
```
php -v

and

ls -l
```

## Load Env Vars into Docker Build
``` php

    #[DaggerFunction('laravel-app-env-vars')]
    public function laravelAppEnvVars(
        #[DaggerArgument('The source code directory')]
        Directory $source,
    ): string {

        $container = $this->laravelAppBuild($source);

        $container = $this->loadEnvArgs($container, $source);

        return $container->withExec(['env'])->stdout();
    }


    private function loadEnvArgs(Container $container, Directory $source): Container
    {
        $envContents = $source->file('.env')->contents();
        $envVars = parse_ini_string($envContents);

        foreach($envVars as $envVarKey => $envVarValue) {
            $container = $container->withEnvVariable($envVarKey, $envVarValue);
        }

        return $container;
    }

```

```
dagger develop && dagger functions
```

### See all the vars from .env now loaded 
```
dagger call laravel-app-env-vars --source=.
```

## Database Service

### Functions for loading the Environment Variables in general

``` php

    private function loadContainerEnvVars(Container $container, Directory $source, string $prefix = ''): Container
    {
        $envVars = $this->getEnvVars($source, $prefix);

        foreach($envVars as $envVarKey => $envVarValue) {
            $container = $container->withEnvVariable($envVarKey, $envVarValue);
        }

        return $container;
    }

    private function getEnvVars(Directory $source, string $prefix = ''): array
    {
        $envContents = $source->file('.env')->contents();
        $envVars = parse_ini_string($envContents);
        $return = [];

        foreach($envVars as $envVarKey => $envVarValue) {
            if($prefix === '') {
                $return[$envVarKey] = $envVarValue;
                continue;
            }

            if($prefix !== '' && str_starts_with($envVarKey, $prefix)) {
                $return[$envVarKey] = $envVarValue;
            }
        }

        return $return;
    }
```

### Load DB_* env vars, and load up MariaDB as a dagger/docker service

``` php
    private function getDbService(
        #[DaggerArgument('The source code directory')]
        Directory $source,
    ): Service {

        $dbEnvVars = $this->getEnvVars($source, 'DB_');

        $service = $this->client->container()->from('mariadb:lts-jammy')
            ->withEnvVariable('MARIADB_DATABASE', $dbEnvVars['DB_DATABASE'])
            ->withEnvVariable('MARIADB_USER', $dbEnvVars['DB_USERNAME'])
            ->withEnvVariable('MARIADB_PASSWORD', $dbEnvVars['DB_PASSWORD'])
            ->withEnvVariable('MARIADB_ROOT_PASSWORD', $dbEnvVars['DB_ROOT_PASSWORD'])
            ->withExposedPort(3306)
            ->asService();

        return $service;
    }
```

### Putting it all together
``` php
    #[DaggerFunction('run-integration-tests')]
    public function runIntegrationTests(
        #[DaggerArgument('The source code directory')]
        Directory $source,
    ): string {

        $container = $this->laravelAppBuild($source);
        $container = $this->loadContainerEnvVars($container, $source);

        // Attach MariaDB
        $dbService = $this->getDbService($source);
        $container = $container->withServiceBinding('database', $dbService);

        # Run Migrations and Tests
        return $container
            ->withExec($this->cmd('php artisan migrate'))
            ->withExec($this->cmd('php artisan db:seed'))
            ->withExec(['./vendor/bin/phpunit'])
            ->stdout();
    }
```

# EXTRAS

Jeremy's module for loading all .env vars into the Container
https://daggerverse.dev/mod/github.com/quartz-technology/daggerverse/magicenv@627fc4df7de8ce3bd8710fa08ea2db6cf16712b3
- [ ] make generic function, to return the values ..
- [ ] make function to return only the DB values
        db = dag.mariadb(version="latest", db_name="foo", db_user="bar", db_password="baz").serve()

docker-compose version is ...
mariadb:lts-jammy


### dagger install the mysql module, and then run dagger develop

```
dagger install mysql

Maybe check out base
https://daggerverse.dev/mod/github.com/levlaz/daggerverse/mariadb@250b1d6bc506b9ab68fe5cfce44ce8ed1c5763b9#Mariadb.base
https://daggerverse.dev/mod/github.com/levlaz/daggerverse/mariadb@cea1668da940b45864116049bd20087855c8c787
```

### take the setup.sh tasks, or the docker-compose exec tasks and move them to ->withExec()
```
->withExec(php artisan migrate)
->withExec(php artisan db:seed)
```

### maybe make this a base() function

### call it from dagger call integration-tests

```
->withExec()
./vendor/bin/phpunit --testdox
```

### show on dagger cloud

### create a ->terminal('docker-compose exec database mysql --user=root -pdb_password app_db') command

## GitHub Actions

### push all code to your repo
```
git add . && git commit -m "commit" && git push
```

### add .yml file
```
```

### install github actions .yml

# EXTRAS


## taking a PHP image that doesn't have compose binary in it, and do a FROM and then run a composer install --dev

### mount a composer.json file <-- make a sample one?
### bring over composer binary
### withExec("composer install --dev")

## When mounting code directories, add to exclude file, in dagger.json, but can also exlude from dagger paramteter

dagger.json
``` json
  "exclude": [
    "**/vendor"
  ],
```
