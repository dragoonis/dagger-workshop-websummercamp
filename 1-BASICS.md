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
             ->withMountedDirectory('/tmp/app', $directory)
             ->withWorkdir('/tmp/app')
             ->withExec(["grep", '-R', $pattern, '.'])
             ->stdout();
    }
```

### Add cmd() function for easyness
``` php
     private function cmd(string $cmd): array
     {
        return ["/bin/sh", "-c", $cmd];
     }
```

### Change grep line to this

``` php
    ->withExec($this->cmd("grep -R $pattern"))
```

### Re-run it with cmd() exec now
```
dagger call grep-dir --directory=. --pattern=Trust

```


## TERMINAL MODE!!!

Add this to your file

Make use `use Dagger\Terminal;` is at the top of the file

``` php
     #[DaggerFunction('Search a directory for lines matching a pattern')]
    public function terminal(
         #[DaggerArgument('The directory to mount')]
         Directory $directory,
    ): Terminal {
         return $this->client->container()->from('alpine:latest')
             ->withMountedDirectory('/tmp/app', $directory)
             ->withWorkdir('/tmp/app')
             ->terminal();
    }
```

### Bring in the new definitions
```
dagger develop && dagger functions
```

### Run the terminal
```
dagger call terminal --directory=.
```
