# State store

## Installation

`gem install state_store`

For Rails add this in you Gemfile

`gem state_store, '~>0.0.2'`

And then run

`bundle install`

## Usage

State store all to keep different states in one attribute.
It provide module for mixin, it is pure ruby so it is possible to use it in any ruby class.
 
```ruby
   class MyFile
      include StateStore
      attr_accessor :permission

      has_states :read,:write,:execute, :in => :permission
   end

   file = MyFile.new
   file.states = [:read,:write]
   file.permission #=> 5
   file.states #=> [:read,:write]
```

It is possible to configure behaviour for #has_states

* **:in** is method name where states are stored in numeric format
* **:as** allow to change method for states (default is :states). This is useful if you have more than one state attribute per class.


## Copyright

Copyright (c) 2012 Arturs Meisters. See LICENSE.txt for
further details.

