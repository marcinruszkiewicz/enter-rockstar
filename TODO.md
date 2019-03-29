# 0.2

Features:

- [x] CLI for scraping lyrics and parsing them to JSON datasets
- [x] Initial dataset from Heavy Metal lyrics included in the gem
- [x] Random strategy and CLI for generating poetic representations of numbers
- [x] Make sure that the generator works with both Floats and Integers
- [x] Gzip/Gunzip data JSONs for smaller file sizes
- [ ] Generator should fall back on bundled token set

Other:

- [x] Better progress indicator for parsing files
- [ ] Test the wikia scraper fully
- [x] Test generating poetic representations
- [ ] Test CLI
- [x] Fix tests on Ruby 2.3 and 2.4
- [ ] Make sure that the basic tokens gzip is distributed with the gem so it's actually useful without spending
      a day on scraping wikia

# Future improvements

- [ ] Add better generation strategies so the generated numbers potentially make more sense
- [ ] Add a complex generator that generates variable names together with numbers
- [ ] Add a translator so you can write minimal Rockstar and translate it automatically to proper Rockstar code
