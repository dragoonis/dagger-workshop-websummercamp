
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



## docker build from existing dockerfile (current webapp)



### add ->env builder for PHP image and MySQL image 
Jeremy's module for loading all .env vars into the Container
https://daggerverse.dev/mod/github.com/quartz-technology/daggerverse/magicenv@627fc4df7de8ce3bd8710fa08ea2db6cf16712b3
- [ ] make generic function, to return the values ..
- [ ] make function to return only the DB values
        db = dag.mariadb(version="latest", db_name="foo", db_user="bar", db_password="baz").serve()



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
