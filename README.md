Deebee
======

> Web client for your DB

## Setup

Clone this repo, then set the `DATABASE_URL` environment variable in your [`.rbenv-vars`](https://github.com/sstephenson/rbenv-vars) or wherever you see fit.

    bundle install
    shotgun start

If you don’t use Postgres, change `gem 'pg'` to something else in the `Gemfile`.

You mostly want this protected, so just set the `HTTP_USERNAME` and `HTTP_PASSWORD` environment variables too.

## TODO

- `UPDATE` + `INSERT` functionality
- Sorting
- Filtering

---

© 2013 [Rafaël Blais Masson](http://rafbm.com)
