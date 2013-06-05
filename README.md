# Deebee — Web client for your DB

Deebee is a convenient and fast web interface for your DB. As a Sinatra app, it can be used standalone or mounted within your Rails app.

## Rails setup

Just like Rails itself, Deebee first tries to connect to the `DATABASE_URL` environment variable, then fallbacks to `database.yml`.

```ruby
# Gemfile
gem 'deebee'
```

```ruby
# config/routes.rb
mount Deebee::App => '/deebee'
```

### Authentication

The preferred way of securing Deebee is through HTTP basic auth:

```ruby
# config/initializers/deebee.rb
unless Rails.env.development?
  Deebee::App.use Rack::Auth::Basic do |username, password|
    username == 'username' && password == 'password'
  end
end
```

[ActiveAdmin](http://activeadmin.info) users can also take advantage of existing `admin_users`:

```ruby
# config/initializers/deebee.rb
unless Rails.env.development?
  Deebee::App.use Rack::Auth::Basic do |email, password|
    if user = AdminUser.where(email: email).first
      BCrypt::Password.new(user.encrypted_password) == password
    end
  end
end
```

## Standalone usage

For standalone use (dead-simple deployment on [Heroku](http://www.heroku.com)), see <http://github.com/rafBM/deebee/tree/master/examples/standalone>

## TODO

- `UPDATE` + `INSERT` functionality
- Sorting
- Filtering

---

© 2013 [Rafaël Blais Masson](http://rafbm.com). Deebee is released under the MIT license.
