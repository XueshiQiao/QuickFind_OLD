//
//  QuickFind.m
//  QuickFind
//
//  Created by Joey on 11/29/14
//  Copyright (c) 2014 www.joeyio.com. All rights reserved.
//

#import "QuickFind.h"
#import "IDEEditorContext.h"

typedef NS_ENUM(NSUInteger, QuickFindType) {
    QuickFindTypeSourceEditor = 0,
    QuickFindTypeConsoleEditor = 1
};

static QuickFind *sharedPlugin;

@interface QuickFind()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic, copy) NSString *selectedText;
@property (nonatomic, strong) NSMenuItem *menuItem;
@property (nonatomic, assign) QuickFindType quickFindType;

@end

@implementation QuickFind

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        _bundle = plugin;
        
        _quickFindType = QuickFindTypeSourceEditor;
        
        // Create menu items, initialize UI, etc.
        // Sample Menu Item:
        NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Find"];
        if (menuItem) {
            [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
            NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Quick Find" action:@selector(doMenuAction) keyEquivalent:@""];
            [actionMenuItem setTarget:self];
            [[menuItem submenu] addItem:actionMenuItem];
        }
        _menuItem = menuItem;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(selectionDidChange:)
                                                     name:NSTextViewDidChangeSelectionNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)selectionDidChange: (NSNotification*) notification {
    if ([[notification object] isKindOfClass:[NSTextView class]]) {
        NSTextView* textView = (NSTextView *)[notification object]; //IDEConsoleTextView and DVTSourceTextView
        
        BOOL validTextView = NO;
        if ([textView isKindOfClass:[DVTSourceTextView class]]) {
            self.quickFindType = QuickFindTypeSourceEditor;
            validTextView = YES;
        } else if ([textView isKindOfClass:[IDEConsoleTextView class]]){
            self.quickFindType = QuickFindTypeConsoleEditor;
            validTextView = YES;
        }
        
        if (validTextView) {
            NSArray* selectedRanges = [textView selectedRanges];
            if (selectedRanges.count > 0) {
                NSRange selectedRange = [[selectedRanges objectAtIndex:0] rangeValue];
                if (selectedRange.length != 0) {
                    self.selectedText = [textView.textStorage.string substringWithRange:selectedRange];
                    NSLog(@"=======Quick Find====== text: %@", self.selectedText);
                }
            }
        }
    }
}

- (void)doMenuAction {
    
    
    switch (self.quickFindType) {
        case QuickFindTypeSourceEditor: {
            IDEEditorContext *context = [self currentEditorContext];
            DVTFindBar *findBar = [context _findBar];
            findBar.findString = self.selectedText;
            [context find:self.menuItem]; //show findbar and find, the paramater is sender
            if (self.selectedText.length > 0) {
                [context findNext:nil]; //highlight the next one
            }
        }
            break;
        case QuickFindTypeConsoleEditor: {
            IDEConsoleArea *consoleArea = [self consoleArea];
            DVTFindBar *findBar = [consoleArea _findBar:NO];
            findBar.findString = self.selectedText;
            [consoleArea find:self.menuItem]; //show findbar and find, the paramater is sender
            if (self.selectedText.length > 0) {
                [consoleArea findNext:nil]; //highlight the next one
            }
        }
            
            break;
        default:
            break;
    }

    //The code is so simple, ha? But actually it takes me 2+ hours to find it.
}

- (IDEEditorContext *)currentEditorContext {
    NSWindowController *currentWindowController = [[NSApp keyWindow] windowController];
    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        IDEWorkspaceWindowController *workspaceController = (IDEWorkspaceWindowController *)currentWindowController;
        IDEEditorArea *editorArea = (IDEEditorArea *)[workspaceController editorArea];
        return [editorArea lastActiveEditorContext];
    }
    return nil;
}

- (IDEConsoleArea *)consoleArea {
    NSWindowController *currentWindowController = [[NSApp keyWindow] windowController];
    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        IDEWorkspaceWindowController *workspaceController = (IDEWorkspaceWindowController *)currentWindowController;
        IDEEditorArea *editorArea = (IDEEditorArea *)[workspaceController editorArea];
        IDEDefaultDebugArea *debugArea = (IDEDefaultDebugArea *)editorArea.activeDebuggerArea;
        return [debugArea consoleArea];
    }
    return nil;
}

@end
