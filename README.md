<h1 align="center">
  MAL Heatmap
</h1>

<h4 align="center">
  <a href="https://github.com/andersonkrs/malheatmap/actions/workflows/ci.yml"><img src="https://github.com/andersonkrs/malheatmap/actions/workflows/ci.yml/badge.svg"/></a>
  <a href="https://uptime.betterstack.com/?utm_source=status_badge"><img src="https://uptime.betterstack.com/status-badges/v1/monitor/14ang.svg"/></a>
</h4>

<p align="center">
 <a href="https://malheatmap.com">https://malheatmap.com</a>
</p>

<table>
    <tr>
        <td>
          MAL Heatmap is a tool for tracking your anime/manga consumption based on your <a href='https://myanimelist.net'>myanimelist.net</a> recent history.<br>
          This app crawls the recent user history daily and generates a full visualization of all activities like <a href='https://github.blog/2013-01-07-introducing-contributions/'>Github contributions calendar</a>.k
          <br><br>
          It also generates an image of your activities calendar that you can embed into your <a href='https://myanimelist.net'>myanimelist.net</a> profile or forum signature extending your MAL experience.
        </td>
    </tr>
</table>

<table>
  <tr>
    <th>App</th>
    <th>Sign in</th>
  </tr>  
  <tr>
    <td>
      <video src="https://github.com/andersonkrs/malheatmap/assets/3708060/81f3f590-ca46-4f68-9630-5f3afdc50d62" alt="App Demo" width="128" height="128">
    </td> 
    <td>
      <video src="https://github.com/andersonkrs/malheatmap/assets/3708060/d9a045b4-789c-4540-88a6-999af29acc1a" alt="Subscription Demo" width="128" height="128">
    </td> 
  </tr>  
</table>

#### Profile examples

Here are some real user profiles to give you an idea of how it looks like in case you don't have an MAL account:

* [KanchiMoe](https://malheatmap.com/users/KanchiMoe)
* [RudeRedis](https://malheatmap.com/users/RudeRedis)
* [GDjkhp](https://malheatmap.com/users/GDjkhp)

#### Motivation

At first, I made this experiment to play around with some cool Rails features, like [ActiveStorage](https://edgeguides.rubyonrails.org/active_storage_overview.html) and [ActionCable](https://guides.rubyonrails.org/action_cable_overview.html). 
Also, I want to take this opportunity to try web scrapping with Ruby and have a pretty much vanilla Rails experience, which is very different from the apps that I have been working on.

Building an app from zero to deployment has been a great experience, and I feel all its pain standing up from the ground. It's taught me a lot about sysadmin tasks, servers, docker, deployment, etc.

Over the years, I've made several upgrades, adding Turbo, SolidQueue, better caching with Russian Doll caching + HTTP Caching, etc.

#### How it works

The web app displays the processed data, and jobs do the hard and dirty work of crawling, processing, and saving data.

When users subscribe via OAuth, we capture some information based on the token and then start crawling their history. We periodically run the web crawler to keep the user's history current.

The users get a calendar image that can be embedded on their MAL profile or forum signature. The image is generated in the background by taking a screenshot of their profiles using a headless Chrome controlled by [Ferrum](https://github.com/rubycdp/ferrum).

### Future

The plan is to consume data solely from MAL's API and drop the web crawling. That will require some deep reorganization of the code and how the activities are calculated since MAL does not have an API for history usage, and they don't seem to have that in their roadmap.

#### Main Tools

* Ruby on Rails
* SQLite
* SolidQueue
* SolidCache
* Hotwire
* Bulma CSS

#### Dependencies:

* SQLite
* Redis for action cable 
* Ruby
* LibVips for ActiveStorage

Since this app is a classical Rails project, there is nothing special here to set up or run the project.

### Deployment

This app is gloriously self-hosted with [Coolify](https://coolify.io/).

Since I keep this app running from my pocket, I use some space to run it on my tiny VPS. To keep costs low, we use the VPS storage to host the ActiveStorage files.

#### Other Inspirations

* [MAL Signature](https://malsignature.com)
* [anime.plus](https://anime.plus)

<a href="https://www.buymeacoffee.com/andersonkrs" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>
