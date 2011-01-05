Keychain
========

A simple class for working with the Mac OS X keychain.

Reference
=========

To learn more about using the Keychain on OS X, see Apple's [Keychain Services Programming Guide](http://developer.apple.com/library/ios/#documentation/Security/Conceptual/keychainServConcepts/01introduction/introduction.html) and the [Keychain Services Reference](http://developer.apple.com/library/mac/#documentation/Security/Reference/keychainservices/Reference/reference.html).

Tips
====

* You need to be careful about what key-value pairs you have stored in an item's attributes, they can sometimes mess up searches or cause unexpected failures when saving/updating a keychain item.

Example Usage
=============

        # get an item
        item = Keychain::Item.new

        # add some search criteria, you need at least one, options are listed
        # in the keychain services reference 'Attribute Item Keys and Values'
        # section (link above)
        item.attributes.merge!({
                KSecAttrProtocol => KSecAttrProtocolHTTPS,
                KSecAttrServer   => 'github.com'
        })

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
           item.update!({ KSecAttrAccount => 'test' })
           puts item.metadata[KSecAttrAccount]

        else
           puts 'No such item exists, maybe you need different criteria?'
        end

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

