#include <stdint.h>

#define __DISPLAY_WIDTH__ (80)
#define __DISPLAY_HEIGHT__ (25)
#define __VIDEO_MEMORY__MAP__ ((uint8_t *)(0xb8000))

void puts(char *c);
