IFToolbarManager - by Itai Ferber - itaiferber@gmail.com

Introduction
------------

`IFToolbarManager` is a library that provides services for an application that wants fine-grain control over using a selectable toolbar (a toolbar that allows users to select items, not just click on them). Using `IFToolbarManager`, it's very easy to set up and deploy as many selectable toolbars as necessary for an application. For the most part, `IFToolbarManager` is an attempt to bring Brandon Walkin's excellent [`BWSelectableToolbar`](https://bitbucket.org/bwalkin/bwtoolkit/src/b627b745f767/BWSelectableToolbar.h) up to date (especially with Xcode 4's lack of support for Interface Builder plugins); it is clean and efficient, and is both backwards and forwards compatible with almost every version of Xcode.

`IFToolbarManager`, for the most part, does a lot of the necessary work on its own. Once you've got everything set up the way you'd like it, all you have to do is create a manager with a toolbar (that is the bare minimum necessary; for customization, it is recommended that you also supply a delegate) and the rest of the work is done for you.

`IFToolbarManager` uses Mike Ash's [`MAZeroingWeakRef`](https://github.com/mikeash/MAZeroingWeakRef), and includes the files along with a copy of their BSD license. No customization is necessary, just a copy of `MAZeroingWeakRef.h` and `MAZeroingWeakRef.m` will suffice (the files have been edited very slightly to behave differently if Automatic Reference Counting is turned on - read the ARC section for more info).

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

Design Choices
--------------

The largest obstacle in designing `IFToolbarManager` was figuring out how to get .xib files to work correctly. Since Apple discontinued Interface Builder plugins in Xcode 4, custom Interface Builder objects are no longer allowed and permitting custom behavior inside of interface files is incredibly tricky. For that reason, different toolbar panes inhabit different .xib files instead of all fitting under a single file with custom code running it. The main issue with this is that linking intra-xib objects is impossible, or at least very difficult, and intra-xib bindings without any glue code are certainly not possible. For this reason, `IFToolbarManager` has an `encapsulatedObject` property that can be set programmatically by an interface controller from one .xib file and exposed to objects in another file. While access of this property will likely require a small controller class to be written for every 'dependent' .xib file (one that contains `IFToolbarPane`s), it allows for easy access, for instance, to an overarching interface controller found in the 'independent' .xib file (the file that contains the interface controller and the toolbar, e.g. "MainMenu.xib"). In other words, the `encapsulatedObject` property of a given `IFToolbarManager` can hold an instance of `MyUIController`, for custom access inside a dependent .xib file.

While there is great power in this property, for the most part, in many cases it might not even be necessary. `IFToolbarManager` naturally exposes the `toolbar` and `window` properties to objects inside its .xib file, so toolbars running inside a modal window, for instance, have access to that window for closing without needing to 'talk' to a global UI controller. The `encapsulatedObject` property is there for whatever might be necessary to use it for, but is not required by everyone.

This was a design choice made early on in the project, and while it might be revised in the future, it is foreseeably going to stay like this. Unless Apple will decide to reintroduce Interface Builder plugins, there is no direct need to change the foundations of the project, and more time will likely be invested into squashing bugs and other issues.

Automatic Reference Counting
----------------------------

This project is compatible with Clang's Automatic Reference Counting feature, available in Apple Clang 3.0 (included in Xcode 4.2). If the `__has_feature(objc_arc)` macro expands to 1 in the preprocessor, all `-retain`, `-release`, and `-autorelease` calls will be removed from the file and replaced with equivalent ARC-compatible code. Because ARC allows for the use of the `__weak` specifier, `MAZeroingWeakRef` is not needed for weak references, and since `MAZeroingWeakRef` will not compile under ARC, it has been modified to not compile if ARC is turned on. You may even remove MAZeroingWeakRef completely from the project if you have ARC turned on to slim the project down.

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