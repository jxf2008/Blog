## 使用CMake代替QMake

在Qt6之前，Qt官方一直坚持使用自己的QMake工具来构建项目，QMake本身并没有什么问题，但在实际项目中，绝大多数项目使用的构建是CMake，在Boost库中，很早就有提供了QMake转CMake的方法，但实现比较复杂，因此当Qt工程和其他工程位于同一个解决方案时，Qt的QMake和其他大多数工程使用的CMake之间，需要花费大量的精力进行交互，并且很容易出错。

Qt6发布后，Qt6官方终于提供了CMake进行构建，实际上Qt5的后期版本就已经提供CMake构建了，但直到Qt6发布，才系统化的提供CMake构建，并且Qt官方也在Qt6发布时明确指出，应该优先使用CMake来构建Qt项目

## 使用QMake构建Hello Qt项目

首先使用VS新建一个项目，选择“Qt Empty Application”

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/QtNotes/CMake1.png)

构建方式选择“CMake”

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/QtNotes/CMake2.png)

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/QtNotes/CMake3.png)

然后得到一个这样的项目结构

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/QtNotes/CMake4.png)

其中./CMakeLists.txt是当前项目作为子项目，供其他项目调用时的CMake,作为单一工程时，这个CMake可以忽略；而./{ProjectName}/CMakeLists.txt这是负责构建当前项目。

项目内还有一个qt.make，这是Qt6.5之前需要用到的构建内容，由于Qt6.5之前的版本存在的问题，因此不推荐使用，也就是说这个qt.make文件可以忽略；我创建的工程的./{ProjectName}/CMakeLists.txt，如下
```cmake
cmake_minimum_required(VERSION 3.16)
project(CMakeProject LANGUAGES CXX)

include(qt.cmake)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core)
find_package(Qt${QT_VERSION_MAJOR}
    COMPONENTS
        Core
)
qt_standard_project_setup()

qt_add_executable(${PROJECT_NAME} ${PROJECT_SOURCES})

set_target_properties(${PROJECT_NAME}
    PROPERTIES
        WIN32_EXECUTABLE TRUE
)

target_link_libraries(${PROJECT_NAME}
    PUBLIC
        Qt::Core
)
```
这里可以看出我的电脑上同时安装了Qt5和Qt6版本，稍后需要修改这个CMakeList.txt,现在工程中添加一个main.cpp文件

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/QtNotes/CMake5.png)

文件添加完成

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/QtNotes/CMake6.png)

main.cpp文件是最初的HelloQt的代码
```c++
#include <QApplication>
#include <QPushButton>

int main(int argc, char** argv) {
	QApplication app(argc, argv);
	QPushButton btn("Hello Qt");
	btn.show();
	return app.exec();
}
```

接下逐行看下./{ProjectName}/CMakeList.txt的改动,
```cmake
cmake_minimum_required(VERSION 3.16)
project(CMakeProject LANGUAGES CXX)


#这个文件包含了2个Qt在CMake中的2个常用的宏，在大型工程中
#可以将这个文件放在某个位置，所有Qt相关工程都包含同一个qt.make，而不用每个工程里都放一个
include(qt.cmake)


set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

#由于我的电脑上有Qt5和Qt6，因此find_packge()函数必须删除有关Qt5的部分
find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets)

#设置MOC编译开关
set(CMAKE_AUTOMOC ON)

#设置UI编译工具UIC开关，如果你使用纯代码编写界面，这个可以不用打卡，即可以忽略改行
set(CMAKE_AUTOUIC ON)

#上面两行是之前函数qt_standard_project_setup()的内容，该函数位于qt.make内
#如果不使用qt.make，可以像这里直接设置MOC和UIC工具的开关

#这里增加了一个set()函数，用于提供源文件
#由于这个工程只有一个main.cpp文件，如果增加文件，还需要一个
#set(PROJECT_HEADERS MyButton.h)这样的函数
set(PROJECT_SOURCES main.cpp)

#同时qt_add_executable()函数后面也要增加一个变量${PROJECT_HEADERS}用于包含文件
#这个qt_add_executable()其实就是CMake的add_executable()
qt_add_executable(${PROJECT_NAME} ${PROJECT_SOURCES})


#设置该工程为win32的exe程序
set_target_properties(${PROJECT_NAME}
    PROPERTIES
        WIN32_EXECUTABLE TRUE
)

#再次强调，如果电脑里同时包含Qt5和Qt6，需要明确指定链接的库是哪个版本的
target_link_libraries(${PROJECT_NAME}
    PUBLIC
        Qt6::Core
        Qt6::Gui
        Qt6::Widgets
)
```
运行结果

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/QtNotes/CMake7.png)