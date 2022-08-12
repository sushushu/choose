
众所周知，对于逆向或者日常开发dubug来说，[ctcript](https://www.jianshu.com/p/de0beb21fb52)是一个非常棒的工具。
尤其是它里面的```choose``` 功能。
因为它的用法简单传一个类名或者地址进去就能找出内存中该类对象的实例
```choose(ClassName)```
如：
```
cy# choose(MMUINavigationController)
[#"<MMUINavigationController: 0x10d001200>",#"<MMUINavigationController: 0x10e0b7800>"]
cy# choose(UIButton)
[#"<FixTitleColorButton: 0x1115734d0; baseClass = UIButton; frame = (170 18; 130 47); clipsToBounds = YES; opaque = NO; autoresize = LM; layer = <CALayer: 0x111573320>>",#"<UIButton: 0x111575aa0; frame = (234 20; 86 49); opaque = NO; autoresize = LM; layer = <CALayer: 0x1115724a0>>",#"<FixTitleColorButton: 0x1105d1700; baseClass = UIButton; frame = (20 18; 130 47); clipsToBounds = YES; opaque = NO; autoresize = RM; layer = <CALayer: 0x1105d19e0>>"]
```

这么绝的工具如果能在项目工程或者插件里面用就好了。

<br>

##### 那么就来抽离一下吧
ps:以下代码全部拷贝自大神的博客，且需要遵守GPL v3协议。[大神博客](https://await.moe/2015/07/抽离cycript的choose功能/)

 **.h文件对外接口**
```
#import <Foundation/Foundation.h>

@interface choose : NSObject

+ (NSArray *)choose:(NSString *)className;

@end
```

 **.m文件实现**
```
#import "choose.h"
 
#include <objc/runtime.h>
#include <malloc/malloc.h>
#include <mach/mach.h>
#include <set>
 
struct choice {
    std::set<Class> query_;
    std::set<id> result_;
};

struct ObjectStruct {
    Class isa_;
};

static kern_return_t read_memory(task_t task, vm_address_t address, vm_size_t size, void **data) {
    *data = reinterpret_cast<void *>(address);
    return KERN_SUCCESS;
}

static Class * copy_class_list(size_t &size) {
    size = objc_getClassList(NULL, 0);
    Class * data = reinterpret_cast<Class *>(malloc(sizeof(Class) * size));
    for (;;) {
        size_t writ = objc_getClassList(data, (int)size);
        if (writ <= size) {
            size = writ;
            return data;
        }

        Class * copy = reinterpret_cast<Class *>(realloc(data, sizeof(Class) * writ));
        if (copy == NULL) {
            free(data);
            return NULL;
        }
        data = copy;
        size = writ;
    }
}

static void choose_(task_t task, void *baton, unsigned type, vm_range_t *ranges, unsigned count) {
    choice * choice = reinterpret_cast<struct choice *>(baton);
    for (unsigned i = 0; i < count; ++i) {
        vm_range_t &range = ranges[I];
        void * data = reinterpret_cast<void *>(range.address);
        size_t size = range.size;
        if (size < sizeof(ObjectStruct))
            continue;

        uintptr_t * pointers = reinterpret_cast<uintptr_t *>(data);
#ifdef __arm64__
        Class isa = reinterpret_cast<Class>(pointers[0] & 0x1fffffff8);
#else
        Class isa = reinterpret_cast<Class>(pointers[0]);
#endif
        std::set<Class>::const_iterator result(choice->query_.find(isa));
        if (result == choice->query_.end())
            continue;
        size_t needed = class_getInstanceSize(*result);
        size_t boundary = 496;
#ifdef __LP64__
        boundary *= 2;
#endif
        if ((needed <= boundary && (needed + 15) / 16 * 16 != size) || (needed > boundary && (needed + 511) / 512 * 512 != size))
            continue;
        choice->result_.insert(reinterpret_cast<id>(data));
    }
}

@implementation choose

+ (NSArray *)choose:(NSString *)className{
    vm_address_t * zones = NULL;
    unsigned size = 0;
    kern_return_t error = malloc_get_all_zones(0, &read_memory, &zones, &size);
    assert(error == KERN_SUCCESS);

    size_t number;
    Class * classes = copy_class_list(number);
    assert(classes != NULL);

    choice choice;
    Class _class = NSClassFromString(className);
    for (size_t i = 0; i != number; ++i) {
        for (Class current = classes[i]; current != Nil; current = class_getSuperclass(current)) {
            if (current == _class) {
                choice.query_.insert(classes[I]);
                break;
            }
        }
    }
    free(classes);

    for (unsigned i = 0; i != size; ++i) {
        const malloc_zone_t * zone = reinterpret_cast<const malloc_zone_t *>(zones[I]);
        if (zone == NULL || zone->introspect == NULL)
            continue;
        zone->introspect->enumerator(mach_task_self(), &choice, MALLOC_PTR_IN_USE_RANGE_TYPE, zones[i], &read_memory, &choose_);
    }

#if __has_feature(objc_arc)
    NSMutableArray * result = [[NSMutableArray alloc] init];
#else
    NSMutableArray * result = [[[NSMutableArray alloc] init] autorelease];
#endif
    for (auto iter = choice.result_.begin(); iter != choice.result_.end(); iter++) {
        [result addObject:(id)*iter];
    }
    return result;
}
@end
```

<br>

######  需要注意的地方

- ```choose.m```必须要改为```choose.mm``` , 因为引入的<set>是C++库

文件需要在MRC模式下运行，所以需要在**Compile Sources**把```choose.mm```的**Compiler Flags**设置为```-fno-objc-arc```

<br>

###### 我已经将上面的代码写成demo，测试可用。
[demo地址](https://github.com/sushushu/choose)

![image.png](https://upload-images.jianshu.io/upload_images/741440-81b38748c19d58b2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



######  题外话: FLEX里面也有类似的功能  链接在这[在这](https://github.com/Flipboard/FLEX/blob/2a8cdbdb84c45a89ebd48f9caad9c0420609a348/Classes/Utility/FLEXHeapEnumerator.m)
