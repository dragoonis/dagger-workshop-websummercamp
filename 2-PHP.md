
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


# Quality Tooling

## parallel-lint

``` php

    #[DaggerFunction('lint')]
    public function lint(
        #[DaggerArgument('The value to echo')]
        Directory $source,
    ): string {
       return $this->client->container()
           ->from('jakzal/phpqa:latest')
           ->withMountedDirectory('/tmp/app', $source)
           ->withExec(['parallel-lint', '/tmp/app'])
           ->stdout();
    }
```

## phpstan

``` php
    #[DaggerFunction('phpstan')]
    public function phpstan(
        #[DaggerArgument('The value to echo')]
        Directory $source,
    ): string {
       return $this->client->container()
           ->from('jakzal/phpqa:latest')
           ->withMountedDirectory('/tmp/app', $source)
           ->withExec(['phpstan', 'analyse', '/tmp/app'])
           ->stdout();
    }
```

