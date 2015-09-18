---
title: Presenting FeedTicker
---

Allow me to present **FeedTicker**, a new addon for the Firefox browser. The idea
is simple: display web feeds (RSS and Atom) in a moving "ticker" toolbar -- the design
of this website should you give an idea of what that looks like. The idea is also
not mine: FeedTicker is closely modeled after the great [RSS Ticker][1] addon by
[Christopher Finke][2].

Unfortunately, recent changes in Firefox have broken that addon and Christopher
[announced he will no longer develop it][3]. Since I ([who's that?][4]) relied
heavily on his great work, and I had some free time on my hands, I decided to delve
into the depths of Firefox addon development and try to develop a similar addon.

FeedTicker is provided free of charge, no need to register or anything. I hope that
others who also relied on RSS Ticker as well as new users will benefit from it.
If you are interested in trying it out, you can download an early version here:

[FeedTicker v0.0.1-alpha.1][5]

***Please note: This version is an early prerelease. It may (and probably will)
still have quite a few bugs and not always work correctly. Also, FeedTicker is
licensed under [the MIT license][6], therefore its warranty disclaimer applies.***

FeedTicker was written by myself from scratch, it does not use any code from the
original RSS Ticker addon. Unlike RSS Ticker, it is based on the Firefox Addon SDK
and not on the deprecated APIs that RSS Ticker uses. Therefore, it should be supported
by Firefox for the foreseeable future.

If you'd like to see the code, or contribute in any way, please have a look at the
[github repository][7]. Also, if you encounter any issues with the addon, please
let me know by [opening an issue on github][8]. If you do not have a github account,
email me at `feedticker [at] online [dot] de`. I'd be happy about any feedback.

[1]: https://addons.mozilla.org/en/firefox/addon/rss-ticker/ "RSS Ticker on addons.mozilla.org"
[2]: http://www.chrisfinke.com/
[3]: http://www.chrisfinke.com/2015/08/21/my-future-of-developing-firefox-add-ons/
[4]: {{ site.baseurl }}/about/me/
[5]: https://github.com/maul-esel/feed-ticker/releases/tag/v0.0.1-alpha.1 "Download .xpi"
[6]: https://github.com/maul-esel/feed-ticker/blob/master/LICENSE.md
[7]: https://github.com/maul-esel/feed-ticker
[8]: https://github.com/maul-esel/feed-ticker/issues
