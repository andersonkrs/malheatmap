

<h1 align="center">
  MAL Heatmap
</h1>

<h4 align="center">
  <a href="https://github.com/andersonkrs/malheatmap"><img src="https://github.com/andersonkrs/malheatmap/workflows/ci/badge.svg"/></a>
  <a href="https://codeclimate.com/github/andersonkrs/malheatmap/maintainability"><img src="https://api.codeclimate.com/v1/badges/46216781798a6f8f02f9/maintainability" /></a>
  <a href="https://codeclimate.com/github/andersonkrs/malheatmap/test_coverage"><img src="https://api.codeclimate.com/v1/badges/46216781798a6f8f02f9/test_coverage" /></a>
  <a href="https://oss.skylight.io/app/applications/J8hCjPhY5lKe"><img src="https://badges.skylight.io/status/J8hCjPhY5lKe.svg" /></a>
</h4>

<p align="center">
 <a href="https://malheatmap.com">https://malheatmap.com</a>
</p>

<table>
<tr>
<td>
  MAL Heatmap is a tool for tracking your anime/manga consumption based on your <a href='https://myanimelist.net'>myanimelist.net</a> recent history.<br>
  This app crawls the recent user history daily and generates a full visualization of all activities like <a href='https://github.blog/2013-01-07-introducing-contributions/'>Github contributions calendar</a>.
  <br><br>
  It also generates an image of your activities calendar that you can embed into your <a href='https://myanimelist.net'>myanimelist.net</a> profile or forum signature extending your MAL experience. 
</td>
</tr>
</table>

![Demo](.github/app-demo.png?raw=true "Demo")

#### Built with

* [Ruby on Rails](https://rubyonrails.org/)
* [PostgreSQL](https://www.postgresql.org/)
* [Redis](https://redis.io/)
* [Bulma CSS](https://bulma.io/)

#### Motivation

I've made this experiment to play around with some cool Rails features, like [ActiveStorage](https://edgeguides.rubyonrails.org/active_storage_overview.html) and [ActionCable](https://guides.rubyonrails.org/action_cable_overview.html). Also, I want to try web scrapping with ruby and learn a little bit more about it.

Also, this allowed me to test some gems, like [ViewComponent](https://github.com/github/view_component).

#### How it works

The web app just displays the processed data and a set of jobs do the hard and dirty work of crawling, process, save data.

So, when the user subscribes to its profile to be tracked, a job will be triggered to check if the user exists on MAL and then crawl and process the data. While that, the UI will be connected to a channel awaiting a response from the job, once the job is completed, the user will be redirected to his page. After subscribing, a recurring job will repeat the crawling process daily to keep the user's data updated.

<table>
  <tr>
    <th>Demo</th>
  </tr>  
  <tr>
    <td>
      <img src=".github/subscription_demo.gif" alt="Subscription Demo" width="128" height="128">
    </td> 
  </tr>
</table>

#### Developing

Requirements:

* PostgreSQL 12.4+
* Ruby 3.0.2
* Node 14.17.0
* [ImageMagick](https://imagemagick.org/index.php)

Since this app is a classical Rails project, there is nothing special here, to setup project:

```sh
bin/setup
```

This script will create the database and install all dependencies.

To run the app:

```sh
bin/rails server
```

To run unit tests:

```sh
bin/rails test
```

Integration tests:

```sh
bin/rails test:system
```

To run all linters and test suites:

```sh
bin/qa
```

### Deployment

This app is deployed with [Dokku](http://dokku.viewdocs.io/dokku/) hosted on a VPS.

Auxiliary tools:

* [Honeybadger](https://rollbar.com/) for error tracking and uptime monitoring
* [Matomo](https://matomo.org) for analytics
* [Amazon S3](https://aws.amazon.com/s3) as storage service
* [Amazon Cloud Watch](https://aws.amazon.com/cloudwatch) for log management
* [Sidekiq](https://sidekiq.org/) as background job adapter

#### Other Inspirations

* [MAL Signature](https://malsignature.com)
* [anime.plus](https://anime.plus)

<a href="https://www.buymeacoffee.com/andersonkrs" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>
