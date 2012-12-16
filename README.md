Phenomenal Gem [![Build Status](https://secure.travis-ci.org/phenomenal/phenomenal.png)](http://travis-ci.org/phenomenal/phenomenal) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/phenomenal/phenomenal)
===

The Phenomenal Gem is a COP framework for the dynamic programming language Ruby. With this framework, programmers can handle contexts as first-class entities allowing them to adapt the behaviour of their applications dynamically in a clean and structured manner.

See our [website](http://www.phenomenal-gem.com) for more details.


### Requirements

#### From rubygems

    gem install phenomenal
    require "phenomenal"

#### From sources

    git clone https://github.com/phenomenal/phenomenal.git
    require "path_to_phenomenal/lib/phenomenal.rb"

### Examples

#### Base class

    class Foo
      def initialize
        @inst_var = "bar"
      end
      def my_instance_method
        "Base instance(#{@inst_var})"
      end
      def self.my_class_method
        "Base class : #{self.name}"
      end
    end


#### Basic example (examples/example_basic.rb)

    require "phenomenal"
    require "./Foo"

    context :demo do 
      adaptations_for Foo
      adapt :my_instance_method do
        "Adapted instance+#{proceed}"
      end
      adapt_class :my_class_method do
        "Adapted class+#{proceed}"
      end
    end

    f = Foo.new
    puts "===> Default behaviour"
    puts f.my_instance_method (Output: "Base instance(bar)")
    puts Foo.my_class_method  (Output: "Base class : Foo")

    puts "===> :demo context activated"
    activate_context(:demo)   
    puts f.my_instance_method (Output: "Adapted instance+Base instance(bar)")
    puts Foo.my_class_method  (Output: "Adapted class+Base class : Foo")

    puts "===> :demo context deactivated"
    deactivate_context(:demo)
    puts f.my_instance_method (Output: "Base instance(bar)")
    puts Foo.my_class_method  (Output: "Base class : Foo")

  * ```context :demo``` defines/reopen the context called "demo". The block contains all the adaptations specific to this context
  * ```adapt :my_instance_method``` replaces the behaviour of the instance method called "my\_instance\_method". The block specifies the new behaviour of the method.
  * ```adapt_class :my_class_method``` replaces the behaviour of the instance method called "my\_class\_method". The block specifies the new behaviour of the method.
  * ```activate_context(:demo)``` activates the context "demo" which replaces the default behaviour by the one defined in the "demo" context.
  * ```deactivate_context(:demo)``` deactivates the context "demo" which replaces the behaviour defined by the context "demo" by the default one.

#### Advanced example

See "examples/example\_basic.rb" for more advanced examples with combined contexts, features and relationships. All our DSL is detailed [here](http://www.phenomenal-gem.com/api).

### Contributions
If you want to contribute, please:

  * Fork the project.
  * Make your feature addition or bug fix.
  * Add tests for it. This is *very* important.
  * Send a pull request on Github with a clear description.

Tests are executed with

    rake        
  
### Copyright

Copyright (c) 2011-2012 Loïc Vigneron - Thibault Poncelet. See LICENSE for details.
