[![Build Status](https://travis-ci.org/marcinruszkiewicz/enter-rockstar.svg?branch=master)](https://travis-ci.org/marcinruszkiewicz/enter-rockstar)
[![Gem Version](https://badge.fury.io/rb/enter-rockstar.svg)](https://badge.fury.io/rb/enter-rockstar)

# Enter Rockstar - a tool to help with programming in Rockstar

This is a set of tools that help Rockstar programmers create programs in the [Rockstar language](https://github.com/RockstarLang/rockstar).

Basically this allows you (with some setup) to do something like this:

```
$ enter-rockstar poetic 561 lyrics_data/sentenced_tokens.json
agony faster desperation
swept dismay mothafuckin
knees desire melancholic
fears facial destruction
doing sweats generations

```

Which helps greatly with writing cool looking Rockstar programs.

For details on what is done and what I'm still working on, see the TODO.md and CHANGELOG.md files.

## Installation

Install the gem by issuing the following command.

```
$ gem install enter-rockstar
```

This gem works best on a current Ruby version and requires Ruby 2.3 at minimum. Running it on 2.3 has the downside of metal umlauts not being entirely correct as that Ruby version doesn't know how to `.downcase` a capital umlaut letter, which was fixed in 2.4.

If you're not using the umlauts (or at least are careful to only replace lowercase letters with them), all should be fine otherwise.

## Setup

To start working with Enter Rockstar, you will need a word base to generate new lyrics from. To help with that task, the gem includes word data created from the "Heavy Metal" category, which should cover most common lyrics, however you can import a different category if you want.

### Scraping a Wikia category page

You have to start with creating a list of all the pages in the Wikia's category, for example like this:

```
$ enter-rockstar scrape_category power_metal /wiki/Category:Genre/Power_Metal
```

This will create a file in `lyrics_data/wikia_power_metal.json` with all the links to pages in this category. Next you want to scrape actual lyric pages based on the links in the json file:

```
$ enter-rockstar scrape_lyrics power_metal
```

After this command finishes (which might take a long time depending on what category you use), you will have a set of directories with text files in the `lyrics` directory.

### Generating a word base

Now that you have a set of lyrics, it's time to convert them into something that Enter Rockstar can use.

```
$ enter-rockstar tokenize power_metal lyrics/
```

Depending on the amount of lyrics you feed into this command, this can take a lot of time. You should also be aware that lyrics that aren't in English will be skipped, as Rockstar isn't really supporting other human languages right now.

## Generating lyrics

### Finding words for poetic literals

The most common and basic function of Enter Rockstar is just finding interesting words of good length to use in the poetic numeral representations. Finding out what words to use to represent `123` is not as easy as it might sound and this makes it easier:

```
$ enter-rockstar poetic 123 lyrics_data/power_metal_tokens.json --amount 10
```

The second argument should be a json tokens list generated in a previous step. You can also skip it, at which point Enter Rockstar will use its built-in list generated from Heavy Metal category.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/marcinruszkiewicz/enter-rockstar. I'm also available for questions at the [Rockstar Developers Discord Group](https://discord.gg/kEUe5bM)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
