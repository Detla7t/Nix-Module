#include <pipewire/pipewire.h>
#include <spa/param/props.h>
#include <stdio.h>

static void on_object(void *data, struct pw_core *core, uint32_t id,
                      const struct spa_dict *props)
{
    const char *node_name = spa_dict_lookup(props, PW_KEY_NODE_NAME);
    const char *media_name = spa_dict_lookup(props, PW_KEY_MEDIA_NAME);

    printf("Object id: %u\n", id);
    if (node_name)
        printf("  Node Name: %s\n", node_name);
    if (media_name)
        printf("  Media Name: %s\n", media_name);
    printf("\n");
}

int main(int argc, char *argv[]) {
    /* Initialize PipeWire */
    pw_init(&argc, &argv);

    /* Create a main loop, context, and connect to the PipeWire core */
    struct pw_main_loop *loop = pw_main_loop_new(NULL);
    struct pw_context *context = pw_context_new(pw_main_loop_get_loop(loop), NULL, 0);
    struct pw_core *core = pw_context_connect(context, NULL, 0);
    if (!core) {
        fprintf(stderr, "Failed to connect to PipeWire core\n");
        return -1;
    }
    
    printf("Enumerating PipeWire objects...\n\n");

    /* Clean up */
    pw_core_disconnect(core);
    pw_context_destroy(context);
    pw_main_loop_destroy(loop);
    pw_deinit();

    return 0;
}

