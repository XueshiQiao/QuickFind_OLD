#QuickFind

QucickFind is a Xcode Plugin to help you find/search something more quickly and more conveniently.

###Before:
When you want to find something in source code, you may select some text first, and press CMD + C to copy, then press CMD + F and paste, then press Enter to find.

![]()

###Now using QuickFind:
Now with QuickFind, you just need to select something, and press CMD + F, QuickFind will open the find bar, put what you selected in the find bar and start to find. Press CMD + F again to find the next one.

![]()

#Install and configuration
3 steps:
1. Download the latest release, unpack it, and put `QuickFind.xcplugin` file to Xcode Plugin folder `~//Library/Application Support/Developer/Shared/Xcode/Plug-ins`, then restart Xcode. You will see `Quick Find` item in `Find` menu.
2. Remove defualt Find shortcut. Open `Xcode` - `Preferences` - `Key Binding`, remove Shortcut of 'Find' (default is CMD + F)  
3. Add shortcut for QuickFind. Open `System Preferences` - `KeyBoard` - `Shortcuts` - `App Shortcuts`, add a shortcut for Qucick Find like this:
    ![]()
    When you open `Find` menu again, you will see:
    ![]()
4. Done, enjoy~ 
