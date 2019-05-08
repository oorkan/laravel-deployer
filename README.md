	       _            _
	    __| | ___ _ __ | | ___  _   _  ___ _ __
	   / _` |/ _ \ '_ \| |/ _ \| | | |/ _ \ '__|
	  | (_| |  __/ |_) | | (_) | |_| |  __/ |
	   \__,_|\___| .__/|_|\___/ \__, |\___|_|
	             |_|            |___/


## Table of contents

- [Description](#description)
- [How to use?](#how-to-use)
- [Command arguments](#command-arguments)
- [Dependencies](#dependencies)
- [Compatibility](#Compatibility)
- [Future Plans](#future-plans)

## Description

This shell script is designed to automate laravel deployment in staging / live servers. Unlike other scripts on github, which suppose to do the same operation, this script can be helpful for dry deployments, where the source code is not coming from project repository and there's a need to separate `public` and `bootstrap` directories.

A standard laravel environment directory tree looks something like this:

```text
laravel_project_root/
	└── app/
	└── bootstrap/
	└── config/
	└── database/
	└── public/
	└── resources/
	└── routes/
	└── storage/
	└── tests/
	└── vendor/
	└── .editorconfig
	└── .env
	└── ...
``` 

On local machine we can get laravel up and running on `localhost:8000` by doing `composer install`, then `php artisan serve`. But in the real server we will probably have public directory which is usually called `public_html` and located under `/var/www/` (apache). To get laravel work there, we should include in `public_html` only the contents of our laravel app's public directory and everything else (laravel base) outside of it (usually in the parent directory), then locate the correct addresses in `public_html/index.php` file by modifying these lines:

- `require __DIR__.'/../vendor/autoload.php';`
- `require_once __DIR__.'/../bootstrap/app.php'`

So, idealally we'll have this directory tree in our server at the end:

```text
/var/www/
	└── public_html/
		└── css/
		└── js/
		└── .htaccess/
		└── favicon.ico/
		└── index.php/
		└── robots.txt/
	└── laravel_base/
		└── app/
		└── bootstrap/
		└── config/
		└── database/
		└── resources/
		└── routes/
		└── storage/
		└── tests/
		└── vendor/
		└── .editorconfig
		└── .env
		└── ...
```
and these lines in our `public_html/index.php` file:

- `require __DIR__.'/../laravel_base/vendor/autoload.php';`
- `require_once __DIR__.'/../laravel_base/bootstrap/app.php'`

All these operations are taking expensive time and there's a possibility to make mistakes, like forgetting to include `.htaccess` file in the public directory, messing up directory trees etc. This is a place, where `deployer` can help you by automating the stuff with just single command.


## How to use?

- Place the `deployer.sh` in your app's root directory
- Upload the project to your server's public directory
- Make the `deployer.sh` executable by running `chmod +x deployer.sh` command
- Run it with one of these commands: `./deployer.sh` or `/bin/bash deployer.sh`

That's all, you are done!

**Important:**  The script will remove itself from your public directory after executing, but it's always preferable to check your directories after executing the script and don't left there anything unwanted.

## Command arguments

When running the script without any arguments, it will generate a random directory name for you, which starts with underscore and can look something like this:  `_8f02b34ec9ecd57be60b1ea638e3fad0` or `_AecQxo4Q2NmzX4lz` . 

- The first type of dirname is generated when package named `urandom` isn't available in your server's linux core and md5 hash sum will be used to generate random string from server's current datetime. 
- The second type of dirname is generated when `urandom` is there, but this time the directory name's length will be only 16 chars, which is still pretty secure.

This random directory name will be included in your `public_html/index.php` file, so you don't need to worry about that.

## -b | --bootstrap

If you don't like random names, you can just use -b (or --bootstrap) argument to name the laravel base directory as you wish. Here's how:

`./deployer.sh -b laravel_base` or `./deployer.sh --bootstrap laravel_base`

## Dependencies

Script requires following packages to be installed on your server:

- zip `sudo apt install zip` 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; https://packages.debian.org/stretch/utils/zip
- unzip (usually comes with zip) `sudo apt install unzip` 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; https://packages.debian.org/stretch/utils/unzip
- rsync `sudo apt install rsync` 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; https://packages.debian.org/stretch/utils/rsync

## Compatibility

The script requires Laravel version >= 5.8. It is tested only under [Debian](https://www.debian.org/) and Debian-based operating systems, like [Ubuntu](https://www.ubuntu.com/) etc. It should also work in almost every linux, but that's not guaranteed, so please be patient enough to test it first, and only then run with actual project if you are using some other linux OS.

## Future Plans

Right now the script also contains second command argument, which is called servertype. It supposed to set automatic permissions for the site directories (for shared and private servers), but because of many compatibility issues and variety of different server configurations, there's no strict way to handle everything with just single command argument, so this is moved to future implementation.

There's also a wish to support database automatation, project setup/vendoring etc.
