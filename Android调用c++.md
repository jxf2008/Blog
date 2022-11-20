## 新建项目

要求Android Studio 4.x版本，在新建项目时选择“Native C++”

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/Adnroid_c/1.png)

比起普通的安卓工程，添加了C++支持的项目需要选择C++版本，一般选择C++11

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/Adnroid_c/2.png)

创建工程完毕后，在./main目录下多了一个./cpp目录，该目录下有2个自动生成的文件

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/Adnroid_c/3.png)

其中native-lib.cpp是C++文件，该文件内有一个自动生成的C++函数，如果需要别的C++功能，可以在该.cpp文件内添加C++代码，或者添加新的C++文件，而CMakeLists.txt则用于构建C++文件.打开native-lib.cpp文件，代码如下

```c++
//native-lib.cpp
#include <jni.h>  //注释1
#include <string>

extern "C" JNIEXPORT jstring JNICALL
Java_com_example_pointcpp_MainActivity_stringFromJNI(   //注释2
        JNIEnv* env,
        jobject /* this */) {   //注释3
    std::string hello = "Hello from C++";
    return env->NewStringUTF(hello.c_str());  //注释4
}
```

+ 注释1 该头文件用于JNI交互，所有C++文件都必须包含该头文件

+ 注释2 在安卓工程中的C++函数命名和标准的C++命名不同，命名规则为“包名_调用该函数的类名_函数名()”,从该函数命名可以看出，该函数将在MainActivity中被调用，该Activity位于java.com.example包内，该函数被调用时的函数名为stringFromJNI().如果该工程有另一个ActivityLoad,而需要在该Activity内调用一个c++函数prinfInfo(),那该C++函数该命名为Java_com_example_pointcpp_ActivityLoad_printInfo()

+ 注释3 该函数的参数前2位固定，通常不用修改，而调用的C++函数如需要传入参数，可以按照顺序从第3个参数开始，稍后给出示例

+ 注释4 Java使用的String在C++代码中时jstring,该类和c++中的std::string需要转码的转换函数来完成转换

native-lib.cpp文件里的这个函数时系统自动生成的示例函数，接下来添加一个C++函数，该函数接收一个std::string和一个int作为参数，并返回一个std::string，根据上面的命名规则，该函数可以写为
```c++
//native-lib.cpp
extern "C" JNIEXPORT jstring JNICALL
Java_com_example_pointcpp_MainActivity_printCount(JNIEnv* env,jobject /* this */,jstring str , int counts) {
    std::string value = env->GetStringUTFChars(str,JNI_FALSE);
    std::string res;
    for(int i = 0 ; i < counts ; ++i) {
        res += std::to_string(i+1);
        res += ":";
        res += value;
        res += "\n";
    }
    return env->NewStringUTF(res.c_str());
}
```

在完成了C++的代码后，接下来时安卓工程的调用，在自动生成的MainActivity里，相对于不支持C++的工程，多了两处

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/Adnroid_c/4.png)

第一处使用loadLibrary()函数加载C++库，库名是CMakeLists.txt中命名的，第二是使用native加载C++函数,这里没有使用系统提供的示例函数，而是在loadAlgBtn的点击事件中调用了上面添加的printCount()函数，结果为

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/Adnroid_c/5.png)


## 使用C++类

安卓工程中不支持使用C++类，因此需要将C++类封装为函数，才能在安卓工程中使用，一般的做法是每个C++的类，都用一个Java类加以封装。首先，右键“./main/cpp”，选择“New”，选择“C++ Class”

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/Adnroid_c/6.png)

然后输入类名

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/Adnroid_c/7.png)

选择完成后，可以看见./cpp文件下多了2个文件，分别为MxrPoint.h和MxrPoint.cpp。

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/Adnroid_c/8.png)

由于新增了C++文件，因此CMakeListx.txt也要做出对应的修改，修改完成后点击"sync now"

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/Adnroid_c/9.png)

C++的头文件定义了一个类,以及5个类成员函数
```c++
//MxrPoint.h
#ifndef POINTCPP_MXRPOINT_H
#define POINTCPP_MXRPOINT_H

#include <jni.h>
#include <string>

class MxrPoint {
private:
    int X;
    int Y;
public:
    MxrPoint();
    void setPoint(int x, int y);
    int x()const;
    int y()const;
    std::string printPoint()const;
};


#endif //POINTCPP_MXRPOINT_H
```
然后再类的实现文件中，除了实现类的成员函数外，还需要对这些成员函数逐一封装
```c++
//MxrPoint.cpp
#include "MxrPoint.h"

extern "C" JNIEXPORT jlong JNICALL
Java_com_example_pointcpp_MxrPointJ_creatJbj(JNIEnv* env,jobject /* this */) {  //注释5
    auto* ptr = new MxrPoint();
    return (jlong)ptr;
}

extern "C" JNIEXPORT void JNICALL
Java_com_example_pointcpp_MxrPointJ_setPoint(JNIEnv* env,jobject /* this */,jlong ptr,int x ,int y) {  //注释6
    ((MxrPoint*)ptr)->setPoint(x,y);
}

extern "C" JNIEXPORT int JNICALL
Java_com_example_pointcpp_MxrPointJ_x(JNIEnv* env,jobject /* this */,jlong ptr) {
    return ((MxrPoint*)ptr)->x();
}

extern "C" JNIEXPORT int JNICALL
Java_com_example_pointcpp_MxrPointJ_y(JNIEnv* env,jobject /* this */,jlong ptr) {
    return ((MxrPoint*)ptr)->y();
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_example_pointcpp_MxrPointJ_printPoint(JNIEnv* env,jobject /* this */,jlong ptr) {
    std::string res = ((MxrPoint*)ptr)->printPoint();
    return env->NewStringUTF(res.c_str());
}

MxrPoint::MxrPoint():X(0),Y(0) {  //注释7

}

void MxrPoint::setPoint(int x, int y) {
    X = x;
    Y = y;
}

int MxrPoint::x() const {
    return X;
}

int MxrPoint::y() const {
    return Y;
}

std::string MxrPoint::printPoint() const {
    std::string res = "坐标：(";
    res += std::to_string(X);
    res += ":";
    res += std::to_string(Y);
    res += ")";
    return res;
}
```
+ 注释5 这个createObj()函数用于封装MxrPoint类的构造函数，由于C++类无法再安卓工程中使用，因此只能使用指针，因此该函数创建一个MxrPoint对象并返回指向该对象的指针，而C++的指针再安卓工程中用long类型来表示，因此该函数返回一个jlong类型

+ 注释6 MxrPoint类的其他成员函数，都要注意封装，这里每个封装函数的第3个参数（也就是安卓调用该函数时的第一个参数）都是jlong,这是为了方便稍后的Java类

+ 注释7 实现了MxrPoint类的全部成员函数，由于这些成员函数不需要在安卓工程里直接调用，因此其实现和标准的C++完全一致

## 封装Java类

从上面C++文件中的封装函数名可以看出，这些C++函数将在MxrPointJ类中被调用（参加之前的C++函数命名规则），因此需要在安卓工程中添加一个MxrPointJ类（该类名可以任意）。

1[](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/Adnroid_c/10.png)

```java
public class MxrPointJ {
    private long mxrPtr;   //注释8
    private native long creatJbj();
    private native void setPoint(long ptr , int x , int y);
    private native int x(long ptr);
    private native int y(long ptr);
    private native String printPoint(long ptr);

    public MxrPointJ(){
        mxrPtr = creatJbj();   //注释9
    }

    public void setPoint(int x, int y){  //注释10
        setPoint(mxrPtr,x,y);
    }

    public int x(){
        return x(mxrPtr);
    }

    public int y(){
        return y(mxrPtr);
    }

    public String printPoint(){
        return printPoint(mxrPtr);
    }
}
```
+ 注释8 这个long类型用于保存C++的对象指针

+ 注释9 在MxrPointJ的构造函中创建了一个C++对象,并将指向该对象的指针保存在成员变量mxrPtr中

+ 注释10 调用MxrPointJ的成员函数，就通过C++的对象指针来调用C++类成员函数

试验代码与结果

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/Adnroid_c/11.png)
![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/Adnroid_c/12.png)