## 使用QtCreator创建QML工程

第一步“Nwe Project。。。”

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/QtNotes/qml_1_1.png)

第二步 选择“Qt Quick Application”

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/QtNotes/qml_1_2.png)

第三步 设置工程名和工程目录

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/QtNotes/qml_1_3.png)

第四步 选择构建工具，从Qt6开始CMake成为Qt默认的构建工具，实际上Qt5的很多高号的版本也已经默认使用CMake,还在使用QMake的尽早转到CMake上

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/QtNotes/qml_1_4.png)

第五步 选择Qt版本，这里有个比较坑爹的地方，Qt5的很多高号版本，比如我用的Qt5.12，由于只能在线安装，因此安装的Qt Quick要求Qt版本必须是6+的，比如我这里要求6.2以上版本，而我电脑里实际上安装的是Qt5.12，这会引起一个问题，下述

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/QtNotes/qml_1_5.png)

第六步 选择构建套件，这里有个巨坑爹的地方，前一步里，由于我安装的Qt5.12的Qt Quick要求的Qt版本最小为Qt6.2，而我安装的确实Qt5.12，所以这一步会显示“qml no suitable kit found”，唯一的解决方案是使用“MaintenanceTool”工具（该工具一般位于Qt安装目录下），再安装一个Qt6.2

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/QtNotes/qml_1_6.png)

这里直接点“下一步”即可

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/QtNotes/qml_1_7.png)

然后看到了一个完成的QML工程，这个工程有两个文件需要关注下，一个是Main.qml，打开工程里的main.qml文件,可以看到下列代码
```qml
import QtQuick
import QtQuick.Window

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")
}
```
另一个是“Source Files/main.cpp”，包含下列代码。
```c++
#include <QGuiApplication>
#include <QQmlApplicationEngine>


int main(int argc, char *argv[]){
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("HelloQML", "Mail");

    return app.exec();
}
```
从这里可以看出，QtCreator自动生成的代码有两个部分，一个是QML，另一个是C++调用QML。

整个工程可以点击QtCreator左下角的“运行”（绿色三角图标）来运行，QML是一种解释性语言，由于QtCreator为我们生成了c++调用qml的相关代码，使得我们可以直接运行这个工程。关于C++中调用QML的功能在后面的章节详细讲述。

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/QtNotes/qml_1_8.png)

要单独的执行某个XML文件，可以“工具”->“外部”->“Qt Quick”，这里有两个工具，可以看出QML的两个解释器，其中"Qt Quick2 Preview(qmlscene)"已经被声明废弃，会在将来某个版本移除，因此一般都使用“QML utility”

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/QtNotes/qml_1_9.png)

## 命令行执行

QML是一种解释性语言，类似Python，所以最简单的执行方法就是用一个你喜欢的编辑器写好.qml文件，然后在命令行执行

首先在某个目录下创建一个HelloWorld.qml的文件，然后添加下列代码并保存
```qml
import QtQuick 2.3

Rectangle{
    width: 200
    height: 50
    color: "#0022BB"
    Text{
        anchors.centerIn: parent
        text:qsTr("Hello QML")
        color: "red"
    }
}
```
然后使用命令行执行命令
```shell
qml E:/QML/HelloWorld.qml
```
其中qml.exe位于~\Qt\6.5.2\msvc2019_64\bin目录下，确保其已经加入环境变量，如果没有，则需要使用完整路径
```shell
~/Qt/6.5.2/msvc2019_64/bin/qml.exe E:/QML/HelloWorld.qml
```
执行结果为

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/QtNotes/qml_1_10.png)