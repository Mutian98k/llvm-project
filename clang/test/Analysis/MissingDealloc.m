// RUN: clang -analyze -warn-objc-missing-dealloc '-DIBOutlet=__attribute__((iboutlet))' %s --verify
typedef signed char BOOL;
@protocol NSObject  - (BOOL)isEqual:(id)object; @end
@interface NSObject <NSObject> {}
- (void)dealloc;
- (id)init;
@end

typedef struct objc_selector *SEL;

// <rdar://problem/6380411>: 'myproperty' has kind 'assign' and thus the
//  assignment through the setter does not perform a release.

@interface MyObject : NSObject {
  id _myproperty;  
}
@property(assign) id myproperty;
@end

@implementation MyObject
@synthesize myproperty=_myproperty; // no-warning
- (void)dealloc {
  self.myproperty = 0;
  [super dealloc]; 
}
@end

//===------------------------------------------------------------------------===
//  Don't warn about iVars that are selectors.

@interface TestSELs : NSObject {
  SEL a;
  SEL b;
}

@end

@implementation TestSELs // no-warning
- (id)init {
  if( (self = [super init]) ) {
    a = @selector(a);
    b = @selector(b);
  }

  return self;
}
@end

//===------------------------------------------------------------------------===
//  Don't warn about iVars that are IBOutlets.

#ifndef IBOutlet
#define IBOutlet
#endif

@class NSWindow;

@interface HasOutlet : NSObject {
IBOutlet NSWindow *window;
}
@end

@implementation HasOutlet // no-warning
@end

//===------------------------------------------------------------------------===
// <rdar://problem/6380411>
// Was bogus warning: "The '_myproperty' instance variable was not retained by a
//  synthesized property but was released in 'dealloc'"

@interface MyObject_rdar6380411 : NSObject {
    id _myproperty;
}
@property(assign) id myproperty;
@end

@implementation MyObject_rdar6380411
@synthesize myproperty=_myproperty;
- (void)dealloc {
    // Don't claim that myproperty is released since it the property
    // has the 'assign' attribute.
    self.myproperty = 0; // no-warning
    [super dealloc];
}
@end
