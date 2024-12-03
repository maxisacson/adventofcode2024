#import <stdlib.h>
#import <regex.h>

regex_t* alloc_regex_t(void);
void free_regex_t(regex_t* ptr);
