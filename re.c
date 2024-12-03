#import "re.h"

regex_t* alloc_regex_t(void) {
    regex_t* ptr = (regex_t*)malloc(sizeof(regex_t));
    return ptr;
}

void free_regex_t(regex_t* ptr) {
    free(ptr);
}
