
### 众所周知，对于逆向或者日常开发dubug来说，[ctcript](https://www.jianshu.com/p/de0beb21fb52)是一个非常棒的工具。
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

### 那么就来抽离一下吧


####  需要注意的地方

- ```choose.m```必须要改为```choose.mm``` , 因为引入的<set>是C++库

文件需要在MRC模式下运行，所以需要在**Compile Sources**把```choose.mm```的**Compiler Flags**设置为```-fno-objc-arc```

<br>


![image.png](https://upload-images.jianshu.io/upload_images/741440-81b38748c19d58b2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


######  题外话: FLEX里面也有类似的功能  链接在这[在这](https://github.com/Flipboard/FLEX/blob/2a8cdbdb84c45a89ebd48f9caad9c0420609a348/Classes/Utility/FLEXHeapEnumerator.m)
