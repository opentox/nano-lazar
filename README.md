nano-lazar
==========

  nano-lazar for [eNanoMapper](http://www.enanomapper.net/) project.

Dependencies
------------

  nano-lazar depends on a couple of external programs and libraries. All required libraries will be installed with the `gem install nano-lazar` or `bundle install` command. The output should give you more verbose information that can help in debugging (e.g. to identify missing libraries). 

Installation
------------  
  
  ```
  gem install nano-lazar
  ```

  or

  ```
  git clone https://github.com/enanomapper/nano-lazar.git
  cd nano-lazar
  bundle install
  ```

Service
-------

  ```
  nano-lazar-start
  nano-lazar-stop
  ```

  or

  ```
  cd nano-lazar
  unicorn -D
  ```

Browser
-------
  Point your browser to `localhost:8080` (default) or any other port passed within the unicorn start command.

Documentation
-------------
  * [API documentation](http://rdoc.info/gems/nano-lazar)

Copyright
---------

  Copyright (c) 2009-2016 Christoph Helma, Micha Rautenberg, Denis Gebele. See LICENSE for details.
