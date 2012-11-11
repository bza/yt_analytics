#YT_Analytics

## Description

yt_analytics is a ruby gem for the [YouTube Analytics API](https://developers.google.com/youtube/analytics/). This gem allows you to access the Analytics API in an easy way and offers flexibility for the metrics returned. Currently we only support temporal dimensions, but the others will follow soon.

## Installation & Setup

  * Create a youtube account.
  * Create a developer key here http://code.google.com/apis/youtube/dashboard.
  * gem install yt_analytics


Note: yt_analytics requires Oauth2 usage.

####Client with OAuth2

```ruby
client = YTAnalytics::OAuth2Client.new(client_access_token: "access_token", client_refresh_token: "refresh_token", client_id: "client_id", client_secret: "client_secret", dev_key: "dev_key", expires_at: "expiration time")
```

If your access token is still valid (be careful, access tokens may only be valid for about 1 hour), you can use the client directly. Refreshing the token is simple:

```ruby
client.refresh_access_token!
```

You can see more about OAuth2 in the [wiki]( https://github.com/kylejginavan/youtube_it/wiki/How-To:-Use-OAuth-2).

### Temporal Dimension Queries

These dimensions indicate that an Analytics report should aggregate data based on a time period, such as a day, a week, or a month.

## Contributors

* Drew Baumann - http://github.com/drewbaumann
* Sean Stavropoulos - http://github.com/sstavrop

## License

MIT License

Copyright (c) 2012 Fullscreen, inc.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
