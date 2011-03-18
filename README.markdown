Keychain
========

A simple class for working with the Mac OS X keychain.

Design Concept
==============

The API is designed for you to work with the keychain based on
key/value pair matching.

This is a further distilation of how things work with the new Snow
Leopard APIs for accessing the keychain. Ideally things now work in a
much more Rubyish way than they would had you used the originally set
of C functions.

Basics
======

There are 4 categories of key/value pairs that you combine to make
queries.

1. [Item class](http://developer.apple.com/library/mac/#documentation/Security/Reference/keychainservices/Reference/reference.html%23//apple_ref/doc/constant_group/Item_Class_Value_Constants);
this is a mandatory field; but `mr_keychain` currently will
automatically add a class of KSecClassInternetPassword for you (since
that is the only supported class right now).
2. [Item Attributes](http://developer.apple.com/library/mac/#documentation/Security/Reference/keychainservices/Reference/reference.html%23//apple_ref/doc/uid/TP30000898-CH4g-SW5);
there can be zero or more of these.
3. [Search filters](http://developer.apple.com/library/mac/#documentation/Security/Reference/keychainservices/Reference/reference.html%23//apple_ref/doc/uid/TP30000898-CH4g-SW1);
there can be zero or more of these.
4. A
[return type](http://developer.apple.com/library/mac/#documentation/Security/Reference/keychainservices/Reference/reference.html%23//apple_ref/doc/uid/TP30000898-CH4g-SW6);
there must be at least one of these, but more can be
specified. However, most methods in `mr_keychain` will set the return
type for you and prevent you from overriding.

Reference
=========

To learn more about using the Keychain on OS X, see Apple's [Keychain Services Programming Guide](http://developer.apple.com/library/ios/#documentation/Security/Conceptual/keychainServConcepts/01introduction/introduction.html) and the [Keychain Services Reference](http://developer.apple.com/library/mac/#documentation/Security/Reference/keychainservices/Reference/reference.html).

Example Usage
=============

        # get an item
        item = Keychain::Item.new

        # add some search criteria, you need at least one, options are listed
        # in the keychain services reference 'Attribute Item Keys and Values'
        # section (link above)
        item.attributes.merge!(
                KSecAttrProtocol => KSecAttrProtocolHTTPS,
                KSecAttrServer   => 'github.com'
        )

        # work with the entry if it exists
        if item.exists?

           # cache all the metadata and print the account name (user name)
           puts item.metadata![KSecAttrAccount]

           # print the password (needs authorization)
           puts item.password

           # change the password and check it (BE CAREFUL)
           puts item.password = 'test'

           # change the user name and save to the keychain
           # note how you do not need authorization to change the user name
           item.update!( KSecAttrAccount => 'test' )
           puts item.metadata[KSecAttrAccount]

        else
           puts 'No such item exists, maybe you need different criteria?'
        end

TODO
====

- Make the simple cases simpler
- Allow more succinct names for constants and guess the actual values

Caveats
=======

The APIs that this library depends on only have access to internet
passwords right now. The interface should remain the same when/if it
is expanded to include the other types of items that the keychain holds.

Contributing to keychain
========================

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
=========

Copyright (c) 2011 Mark Rada. See LICENSE.txt for
further details.

