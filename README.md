# babel #

* [![Build Status](https://secure.travis-ci.org/mkristian/babel.png)](http://travis-ci.org/mkristian/babel) 
* [![Dependency Status](https://gemnasium.com/mkristian/ixtlan-babel.png)](https://gemnasium.com/mkristian/ixtlan-babel)
* [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/mkristian/ixtlan-babel)

rails comes with `to_json` and `to_xml` on models and you can give them an option map to control how the whole object tree gets serialized.

the first problem I had was that I needed serveral options map at different controllers/actions so I needed a place to store them. the model itself felt to be the wrong place.

the next problem was that I could include the result of a given method with `:methods => ['age']` but only on the root level of the object tree. but if I wanted to `age` method to be part of the serialization somewhere deep inside the object tree, it is not possible.

please have a look at **spec/filter_spec.rb** how to use it :)

TODO usage
==========

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

meta-fu
-------

enjoy :) 

