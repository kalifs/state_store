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
      has_states :big,:bad, :in => :characteristics, :as => :nature
   end

   wolf = Wold.new()
   wolf.nature = [:bad]
   wolf.characteristics #=> 1

```

Then if you decide to add _hungry_ then you change states to

```ruby
   class Wold
      include StateStore
      has_states :hungry, :big, :bad, :in => :characteristics, :as => :nature
   end

   wolf = Wold.new()
   wolf.nature = [:bad]
   wolf.characteristics #=> 1
   wold.nature = [:hungry,:bad]
   wolf.characteristics #=> 5   
```

Now you can create configuration for Wolf instance with configuration.


## Copyright

Copyright (c) 2012 Arturs Meisters. See LICENSE.txt for
further details.

