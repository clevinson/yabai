#include "workspace.h"

extern struct eventloop g_eventloop;

void workspace_event_handler_init(void **context)
{
    workspace_context *ws_context = [workspace_context alloc];
    *context = ws_context;
}

void workspace_event_handler_begin(void **context)
{
    workspace_context *ws_context = *context;
    [ws_context init];
}

void workspace_event_handler_end(void *context)
{
    workspace_context *ws_context = (workspace_context *) context;
    [ws_context dealloc];
}

@implementation workspace_context
- (id)init
{
    if ((self = [super init])) {
       [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                selector:@selector(activeDisplayDidChange:)
                name:@"NSWorkspaceActiveDisplayDidChangeNotification"
                object:nil];

       [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                selector:@selector(activeSpaceDidChange:)
                name:NSWorkspaceActiveSpaceDidChangeNotification
                object:nil];

       [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                selector:@selector(didActivateApplication:)
                name:NSWorkspaceDidActivateApplicationNotification
                object:nil];

       [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                selector:@selector(didDeactivateApplication:)
                name:NSWorkspaceDidDeactivateApplicationNotification
                object:nil];

       [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                selector:@selector(didHideApplication:)
                name:NSWorkspaceDidHideApplicationNotification
                object:nil];

       [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                selector:@selector(didUnhideApplication:)
                name:NSWorkspaceDidUnhideApplicationNotification
                object:nil];
    }

    return self;
}

- (void)dealloc
{
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
    [super dealloc];
}

- (void)activeDisplayDidChange:(NSNotification *)notification
{
    struct event *event;
    event_create(event, DISPLAY_CHANGED, NULL);
    eventloop_post(&g_eventloop, event);
}

- (void)activeSpaceDidChange:(NSNotification *)notification
{
    struct event *event;
    event_create(event, SPACE_CHANGED, NULL);
    eventloop_post(&g_eventloop, event);
}

- (void)didActivateApplication:(NSNotification *)notification
{
    pid_t pid = [[notification.userInfo objectForKey:NSWorkspaceApplicationKey] processIdentifier];

    struct event *event;
    event_create(event, APPLICATION_ACTIVATED, (void *)(intptr_t) pid);
    eventloop_post(&g_eventloop, event);
}

- (void)didDeactivateApplication:(NSNotification *)notification
{
    pid_t pid = [[notification.userInfo objectForKey:NSWorkspaceApplicationKey] processIdentifier];

    struct event *event;
    event_create(event, APPLICATION_DEACTIVATED, (void *)(intptr_t) pid);
    eventloop_post(&g_eventloop, event);
}

- (void)didHideApplication:(NSNotification *)notification
{
    pid_t pid = [[notification.userInfo objectForKey:NSWorkspaceApplicationKey] processIdentifier];

    struct event *event;
    event_create(event, APPLICATION_HIDDEN, (void *)(intptr_t) pid);
    eventloop_post(&g_eventloop, event);
}

- (void)didUnhideApplication:(NSNotification *)notification
{
    pid_t pid = [[notification.userInfo objectForKey:NSWorkspaceApplicationKey] processIdentifier];

    struct event *event;
    event_create(event, APPLICATION_VISIBLE, (void *)(intptr_t) pid);
    eventloop_post(&g_eventloop, event);
}

@end
