IFToolbarManager - by Itai Ferber - itaiferber@gmail.com

Introduction
------------

`IFToolbarManager` is a library that provides services for an application that wants fine-grain control over using a selectable toolbar (a toolbar that allows users to select items, not just click on them). Using `IFToolbarManager`, it's very easy to set up and deploy as many selectable toolbars as necessary for an application. For the most part, `IFToolbarManager` is an attempt to bring Brandon Walkin's excellent [`BWSelectableToolbar`](https://bitbucket.org/bwalkin/bwtoolkit/src/b627b745f767/BWSelectableToolbar.h) up to date (especially with Xcode 4's lack of support for Interface Builder plugins); it is clean and efficient, and is both backwards and forwards compatible with almost every version of Xcode.

`IFToolbarManager`, for the most part, does a lot of the necessary work on its own. Once you've got everything set up the way you'd like it, all you have to do is create a manager with a toolbar (that is the bare minimum necessary; for customization, it is recommended that you also supply a delegate) and the rest of the work is done for you.

`IFToolbarManager` uses Mike Ash's [`MAZeroingWeakRef`](https://github.com/mikeash/MAZeroingWeakRef), and includes the files along with a copy of their BSD license. No customization is necessary, just a copy of `MAZeroingWeakRef.h` and `MAZeroingWeakRef.m` will suffice.

Setup
-----

Most of the work in using `IFToolbarManager` is performing the setup properly. This is mostly manual work done in Interface Builder and will not be done programmatically. In an attempt to alleviate some of the pain of debugging mistakes made in Interface Builder (come on, how many of you have hit your head against the wall when you realized that the mysterious bug you've been seeing is simply a forgotten IB binding?), any errors that `IFToolbarManager` encounters will be logged in order to better assess the problem.

The workflow of setting up a manager goes like this:

  1. Plan out your toolbar. Figure out which items you would like on it, their appropriate titles and icons, and create those necessary resources.
  2. Create a new, empty .xib file. You may call it anything you wish, but if it is to differ from the identifier you give your `IFToolbarManager`, you will have to declare that in a delegate method (i.e. a toolbar manager with the identifier `@"Toolbar"` will search for a file called "Toolbar.xib" or "Toolbar.nib" to load, unless specified otherwise by the toolbar manager's delegate).
  3. Set the file's owner of the .xib to `IFToolbarManager`. This will also allow you to send `selectNextPane:` and `selectPreviousPane:` messages to the manager.
  4. For every toolbar item you wish to add to the toolbar, add a new `NSObject` to the file and set its class to `IFToolbarPane` (you must now set runtime attributes for it to follow; see `IFToolbarPane`'s documentation for exact details). Then, add the view you would like to associate with it and link them.
  5. In code, create a new toolbar and toolbar manager. Either give the manager the same identifier as the .xib file, or give it a different one and tell it to look for a specific .xib file through a delegate. Customize behavior using that delegate.
  6. Simply repeat for every toolbar you would like to include in your program.

If you've made a mistake along the way, and have set the manager's error reporting level to 1 (as opposed to 0), it will let you know about any errors it encounters (and attempts to recover from). If the error reporting level is set to 0, it will silently either ignore the affected areas (if allowed), attempt to repair the issue, or abort if no other option is available.

App Store
---------

No code included in `IFToolbarManager` makes use of private APIs, but special care is to be taken with `MAZeroingWeakRef`. The copy of `MAZeroingWeakRef` included with the sample project has its 'hackery' level set to 0 (it won't trip off any problems with App Store submissions), but if you decide to include your own copy, make sure `COREFOUNDATION_HACKERY_LEVEL` is indeed set to 0.

Source Code
-----------

The project source code is available on GitHub (in fact, you're most likely already viewing it there):

    http://github.com/itaiferber/IFToolbarManager/

The source code is bundled under an MIT license, so you're pretty much free to do with it as you wish.
Sample icons included come from Marcelo Marfil's royalty-free 32px Corner Stone icon set. Shoutout for the great work!

More Information
----------------

Additional documentation can be found in the source code, if needed (header files are extensively documented).
Any outstanding questions you might have will be gladly taken at my email address (supplied above).

Enjoy!

(This readme file was unabashedly copied from Mike Ash's MAZeroingWeakRef project – honestly, I don't know how to write these! I used his as a template.)