# ["Badges? We don't need no stinking badges!"](http://en.wikipedia.org/wiki/Stinking_badges "Wikipedia Stinking Badges Page")

*There was a time of simplicity and innocence. An Eden of love and trust, where everyone behaved as angels.  Doors were never barred, nor gates sealed.  Everything is allowed when none desire but the best of all worlds...*

*And then you pushed those first commits, and heroku brought these perfect forms to imperfect incarnation, and you inevitably awoke, realizing that there must be Rule of Law.  But just as these imperfect mortals must be corrected and corralled, so too must the system of rules be open to change and adjustment, for mistakes may be made there as well, and not all rules stand the test of time, nor the foibles of admins or managers.*

Badges is an authorization plugin with a few key differences from others out there in open source land (or else, what would be the point?).

The focus is on creating roles that have lists of privileges, and those features are meant to be understandable outside of the code.

For example, rather than saying an admin role has the privilege to perform the (new and) create on the Post model, as well as to the PostAttachement model, and all other blog post related classes, you would say the admin role has the 'create blog posts' privilege, and ensure in the code that this is what is checked wherever appropriate.  Then an admin can decide to enable or disable this feature for a role without every knowing the implementation details, methods, or class names involved.  

This is an intentional abstraction; our aim is to create a feature (or story) level description for each privilege that can be managed by non-developers, but let the developers use these privileges and correctly apply them in the code.

Anther aspect of this design is to use it as a way to disable features temporarily, or to enable features only for alpha/beta users.  This becomes much easier when it is a matter of assigning the new feature related privileges to a role, and that role to all your beta users.  Then, when the beta is over, enable that privilege to everyone.

While roles and privileges need to be readable and understandable, how they are assigned can be a bit more complicated.

[to be continued]
