# API-ADMIN-MANAGER-ERP

## requirements
* You must have installed <b>Docker >= 20.10.21</b>
* You must have installed <b>Docker-compose >= 1.29.2</b>

## install
```shell
$ cp .env.example .env

# you must edit your enviroment variables
# this is example edit document with vim, but
# you can use your editor favorite
$ vim .env

# create the images about project
$ docker-compose build

# this command will execute the migrations and seeders
$ docker-compose run web rails db:create db:migrate db:seed
```

# start web app
```shell
$ docker-compose up -d
```

## test units
```shell
$ docker-compose exec web rspec
```
