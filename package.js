Package.describe({
  name: 'new3rs:twitter',
  version: '1.1.0',
  // Brief, one-line summary of the package.
  summary: 'a synchronous wrapper of NPM twitter',
  // URL to the Git repository containing the source code for this package.
  git: 'https://github.com/new3Rs/meteor-twitter.git',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Npm.depends({
  "twitter": "git+https://github.com/y-ich/node-twitter"
});

Package.onUse(function(api) {
  api.versionsFrom('1.6.1');
  api.use('coffeescript@2.0.3')
  api.addFiles('twitter.coffee', 'server');
  api.export('Twitter', 'server');
});

Package.onTest(function(api) {
  api.use('coffeescript');
  api.use('tinytest');
  api.use('new3rs:twitter');
  api.addFiles('twitter-tests.coffee', 'server');
});
