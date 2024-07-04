
# install pre-created PHP module

```
dagger install github.com/carnage/dagger-php-module
```

#  adding extensions using php module
``` php
     #[DaggerFunction('Echo the value to standard output')]
     public function phpBase(): string {
        $container = $this->client->php()->cli('8.2');
        foreach(['pdo-sqlite', 'gd'] as $ext) {
            $container = $this->client->php()->withExtension($container, $ext);
        }
        
        return $container->withExec(['php', '-m'])
            ->stdout();
     }
``` 

# build the laravel app image with it

``` php
     private function getLaravelPhpEnv(): Container
     {
        $container = $this->client->php()->cli('8.2');
        $container = $this->client->php()->withExtension($container, 'pdo_mysql');
        $container = $this->client->php()->withExtension($container, 'intl');
        $container = $this->client->php()->withExtension($container, 'gmp');
        $container = $this->client->php()->withExtension($container, 'gd');

        // @todo - now in the workshop, change this to a loop, and watch it ALL still be cached.

        return $container;
     }
```