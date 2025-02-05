#include "space.h"

extern int g_connection;

CFStringRef space_display_uuid(uint64_t sid)
{
    return SLSCopyManagedDisplayForSpace(g_connection, sid);
}

uint32_t space_display_id(uint64_t sid)
{
    CFStringRef uuid_string = space_display_uuid(sid);
    if (!uuid_string) return 0;

    CFUUIDRef uuid = CFUUIDCreateFromString(NULL, uuid_string);
    uint32_t id = CGDisplayGetDisplayIDFromUUID(uuid);

    CFRelease(uuid);
    CFRelease(uuid_string);

    return id;
}

uint32_t *space_window_list_for_connection(uint64_t sid, int cid, int *count)
{
    uint32_t *window_list = NULL;
    uint64_t set_tags = 0;
    uint64_t clear_tags = 0;

    CFNumberRef space_id_ref = CFNumberCreate(NULL, kCFNumberSInt32Type, &sid);
    CFArrayRef space_list_ref = CFArrayCreate(NULL, (void *)&space_id_ref, 1, NULL);
    CFArrayRef window_list_ref = SLSCopyWindowsWithOptionsAndTags(g_connection, cid, space_list_ref, 0x2, &set_tags, &clear_tags);
    if (!window_list_ref) goto err;

    *count = CFArrayGetCount(window_list_ref);
    if (!*count) goto out;

    window_list = malloc(*count * sizeof(uint32_t));

    for (int i = 0; i < *count; ++i) {
        CFNumberRef id_ref = CFArrayGetValueAtIndex(window_list_ref, i);
        CFNumberGetValue(id_ref, CFNumberGetType(id_ref), window_list + i);
    }

out:
    CFRelease(window_list_ref);
err:
    CFRelease(space_list_ref);
    CFRelease(space_id_ref);
    return window_list;
}

uint32_t *space_window_list(uint64_t sid, int *count)
{
    return space_window_list_for_connection(sid, 0, count);
}

CFStringRef space_uuid(uint64_t sid)
{
    return SLSSpaceCopyName(g_connection, sid);
}

int space_type(uint64_t sid)
{
    return SLSSpaceGetType(g_connection, sid);
}

bool space_is_user(uint64_t sid)
{
    return space_type(sid) == 0;
}

bool space_is_fullscreen(uint64_t sid)
{
    return space_type(sid) == 3;
}

bool space_is_system(uint64_t sid)
{
    return space_type(sid) == 2;
}

bool space_is_visible(uint64_t sid)
{
    return sid == display_space_id(space_display_id(sid));
}
