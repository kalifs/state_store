# State store
[![Build Status](https://secure.travis-ci.org/kalifs/state_store.png?branch=master)](http://travis-ci.org/kalifs/state_store)
[![Gemnasium status](https://gemnasium.com/kalifs/state_store.png)](https://gemnasium.com/kalifs/state_store)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/kalifs/state_store)

## Installation

`gem install state_store`

`require 'state_store'`

For Bundler add this in you Gemfile

`gem state_store, '~>0.1.0'`

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
   file.has_permission?(:read) #=> true
   file.has_permission?(:execute) #=> false
   file.permission #=> 5
   file.states #=> [:read,:write]
```

It is possible to configure behaviour for #has_states

* **:in** is method name where states are stored in numeric format
* **:as** allow to change method for states (default is :states). This is useful if you have more than one state attribute per class.

### Adding new states

When you need to add new states and you keep want to previous states configurations be valid, then you should add new state as first in queue.

```ruby 
   class Wolf
      include StateStore
      has_states :big,:bad, :in => :characteristic, :as => :nature
   end

   wolf = Wolf.new()
   wolf.nature = [:bad]
   wolf.characteristic #=> 1

```

Then if you decide to add _hungry_ then you change states as shown below and that will keep previous configuration valid as well as new one.

```ruby
   class Wolf
      include StateStore
      has_states :hungry, :big, :bad, :in => :characteristic, :as => :nature
   end

   wolf = Wolf.new()
   wolf.nature = [:bad]
   wolf.characteristic #=> 1
   wolf.nature = [:hungry,:bad]
   wolf.has_charasteristic?(:bad) #=> true
   wolf.characteristic #=> 5   
```

### Changing states

It is possible to alter states Array and changes storage attribute will be updated automaticly.

```ruby
   class Apple
     attr_accessor :status
     include StateStore
     has_states :big, :red, :"with-worm", :in => :status
   end

   apple = Apple.new
   apple.states = [:big,:red]
   apple.status #=> 6
   apple.states.remove(:red)
   apple.status #=> 4
   apple.states.add(:"with-worm")
   apple.status #=> 5
```

But remember if you will modify `states` with other methods, like `<<` or `delete` or others changes will not be stored in status. 


## Copyright

Copyright (c) 2012 Arturs Meisters. See LICENSE.txt for
further details.

