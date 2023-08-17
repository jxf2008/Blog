原文地址：http://www.qtcn.org/bbs/read-htm-tid-91786.html

### 00：直观总结

1. 增加了很多轮子，同时原有模块拆分的也更细致，估计为了方便拓展个管理。
2. 把一些过度封装的东西移除了（比如同样的功能有多个函数），保证了只有一个函数执行该功能。
3. 把一些Qt5中兼容Qt4的方法废弃了，必须用Qt5中对应的新的函数。
4. 跟随时代脚步，增加了不少新特性以满足日益增长的客户需求。
5. 对某些模块和类型及处理进行了革命性的重写，运行效率提高不少。
6. 有参数类型的变化，比如 long * 到 qintptr * 等，更加适应后续的拓展以及同时对32 64位不同系统的兼容。
7. 源码中的double数据类型全部换成了qreal，和Qt内部数据类型高度一致和统一。
8. 我测试的都是QWidget部分，quick部分没有测试，估计quick部分更新可能会更多。
9. 强烈建议暂时不要用Qt6.0到Qt6.2之间的版本，一些模块还缺失，相对来说BUG也比较多，推荐6.2.2版本开始正式迁移。

### 01：01-10

1. 万能方法：安装5.15版本，定位到报错的函数，切换到源码头文件，可以看到对应提示字样 QT_DEPRECATED_X("Use sizeInBytes") 和新函数。按照这个提示类修改就没错，一些函数是从Qt5.7 5.9 5.10等版本新增加的，可能你的项目还用的Qt4的方法，但是Qt6以前都兼容这些旧方法，到了Qt6就彻底需要用新方法了。**PS：如果本身就是Qt6新增的功能函数则此方法无效**

2. Qt6对core这个核心类进行了拆分，多出来core5compat，因此你需要在pro增加对应的模块已经代码中引入对应的头文件。
```cpp
//pro文件引入模块
greaterThan(QT_MAJOR_VERSION, 4): QT += widgets
greaterThan(QT_MAJOR_VERSION, 5): QT += core5compat

//代码中引入头文件
#if (QT_VERSION >= QT_VERSION_CHECK(5,0,0))
#include <QtWidgets>
#endif
#if (QT_VERSION >= QT_VERSION_CHECK(6,0,0))
#include <QtCore5Compat>
#endif
```

3. 默认Qt6开启了高分屏支持，界面会变得很大，甚至字体发虚，很多人会不习惯，因为这种模式如果程序很多坐标计算没有采用devicePixelRatio进行运算的话，100%会出现奇奇怪怪的问题，因为坐标不准确了。要取消这种效果可以设置高分屏缩放因子。
```cpp
#if (QT_VERSION >= QT_VERSION_CHECK(6,0,0))
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(Qt::HighDpiScaleFactorRoundingPolicy::Floor);
#endif
```

4. 原有的随机数函数提示用QRandomGenerator替代，为了兼容所有qt版本，改动最小的办法是直接用c++中的随机数，比如qsrand函数换成srand，qrand函数换成rand，查看过源代码，其实封装的就是c++中的随机数，很多类似的封装比如qSin封装的sin。

5. QColor的 light 改成 lighter ，dark 改成 darker，其实 lighter、darker 这两个方法以前一直有。

6. QFontMetricsF 中的 fm.width 换成 fm.horizontalAdvance ，从5.11开始用新函数。

7. QPalette调色板枚举值，Foreground = WindowText, Background = Window，其中 Foreground 和 Background 没有了，要用 WindowText 和 Window 替代，以前就有。类似的还有 setTextColor 改成了 setForeground 。

8. QWheelEvent的 delta() 改成 angleDelta().y()，pos() 改成 position() 。

9. svg模块拆分出来了svgwidgets，如果用到了该模块则需要在pro增加 QT += svgwidgets ，同理opengl模块拆分出来了openglwidgets。

10. qlayout中的 margin() 函数换成 contentsMargins().left()，查看源码得知以前的 margin() 返回的就是 contentsMargins().left()，在四个数值一样的时候，默认四个数值就是一样。类似的还有setMargin移除了，统统用setContentsMargins。

### 02：11-20

11. 之前 QChar c = 0xf105 全部要改成强制转换 QChar c = (QChar)0xf105，不再有隐式转换，不然编译报错提示error: conversion from 'int' to 'QChar' is ambiguous 。

12. qSort等一些函数用回c++的 std::sort 。
```cpp
#if (QT_VERSION >= QT_VERSION_CHECK(6,0,0))
    std::sort(ipv4s.begin(), ipv4s.end());
#else
    qSort(ipv4s);
#endif
```

13. Qt::WA_NoBackground 改成 Qt::WA_OpaquePaintEvent 。

14. QMatrix 类废弃了没有了，换成 QTransform ，函数功能基本一致，QTransform 类在Qt4就一直有。

15. QTime 计时去掉了，需要改成 QElapsedTimer ，QElapsedTimer 类在Qt4就一直有。

16. QApplication::desktop()废弃了， 换成了 QApplication::primaryScreen()。
```cpp
#if (QT_VERSION > QT_VERSION_CHECK(5,0,0))
#include "qscreen.h"
#define deskGeometry qApp->primaryScreen()->geometry()
#define deskGeometry2 qApp->primaryScreen()->availableGeometry()
#else
#include "qdesktopwidget.h"
#define deskGeometry qApp->desktop()->geometry()
#define deskGeometry2 qApp->desktop()->availableGeometry()
#endif
```

17. 获取当前屏幕索引以及尺寸需要分别处理。
```cpp
//获取当前屏幕索引
int QUIHelper::getScreenIndex()
{
    //需要对多个屏幕进行处理
    int screenIndex = 0;
#if (QT_VERSION >= QT_VERSION_CHECK(5,0,0))
    int screenCount = qApp->screens().count();
#else
    int screenCount = qApp->desktop()->screenCount();
#endif

    if (screenCount > 1) {
        //找到当前鼠标所在屏幕
        QPoint pos = QCursor::pos();
        for (int i = 0; i < screenCount; ++i) {
#if (QT_VERSION >= QT_VERSION_CHECK(5,0,0))
            if (qApp->screens().at(i)->geometry().contains(pos)) {
#else
            if (qApp->desktop()->screenGeometry(i).contains(pos)) {
#endif
                screenIndex = i;
                break;
            }
        }
    }
    return screenIndex;
}

//获取当前屏幕尺寸区域
QRect QUIHelper::getScreenRect(bool available)
{
    QRect rect;
    int screenIndex = QUIHelper::getScreenIndex();
    if (available) {
#if (QT_VERSION >= QT_VERSION_CHECK(5,0,0))
        rect = qApp->screens().at(screenIndex)->availableGeometry();
#else
        rect = qApp->desktop()->availableGeometry(screenIndex);
#endif
    } else {
#if (QT_VERSION >= QT_VERSION_CHECK(5,0,0))
        rect = qApp->screens().at(screenIndex)->geometry();
#else
        rect = qApp->desktop()->screenGeometry(screenIndex);
#endif
    }
    return rect;
}
```

18. QRegExp类移到了core5compat模块，需要主动引入头文件 #include "QRegExp"。
```cpp
    //设置限制只能输入数字+小数位
    QString pattern = "^-?[0-9]+([.]{1}[0-9]+){0,1}$";
    //设置IP地址校验过滤
    QString pattern = "(2[0-5]{2}|2[0-4][0-9]|1?[0-9]{1,2})";

    //确切的说 QRegularExpression QRegularExpressionValidator 从5.0 5.1开始就有
#if (QT_VERSION >= QT_VERSION_CHECK(6,0,0))
    QRegularExpression regExp(pattern);
    QRegularExpressionValidator *validator = new QRegularExpressionValidator(regExp, this);
#else
    QRegExp regExp(pattern);
    QRegExpValidator *validator = new QRegExpValidator(regExp, this);
#endif
    lineEdit->setValidator(validator);
```

19. QWheelEvent构造参数和对应的计算方位函数变了。
```cpp
//模拟鼠标滚轮
#if (QT_VERSION < QT_VERSION_CHECK(6,0,0))
QWheelEvent wheelEvent(QPoint(0, 0), -scal, Qt::LeftButton, Qt::NoModifier);
#else
QWheelEvent wheelEvent(QPointF(0, 0), QPointF(0, 0), QPoint(0, 0), QPoint(0, -scal), Qt::LeftButton, Qt::NoModifier, Qt::ScrollBegin, false);
#endif
QApplication::sendEvent(widget, &wheelEvent);

//鼠标滚轮直接修改值
QWheelEvent *whellEvent = (QWheelEvent *)event;
//滚动的角度,*8就是鼠标滚动的距离
#if (QT_VERSION < QT_VERSION_CHECK(6,0,0))
int degrees = whellEvent->delta() / 8;
#else
int degrees = whellEvent->angleDelta().x() / 8;
#endif
//滚动的步数,*15就是鼠标滚动的角度
int steps = degrees / 15;
```

20. qVariantValue 改成 qvariant_cast ，qVariantSetValue(v, value) 改成了 v.setValue(val)。相当于退回到最原始的方法，查看qVariantValue源码封装的就是qvariant_cast。

### 03：21-30

21. QStyleOption的init改成了initFrom。

22. QVariant::Type 换成了 QMetaType::Type ，本身以前的 QVariant::Type 封装的就是 QMetaType::Type 。

23. QStyleOptionViewItemV2 V3 V4 之类的全部没有了，暂时可以用 QStyleOptionViewItem 替代。

24. QFont的 resolve 的一个重载函数换成了 resolveMask。

25. QSettings的 setIniCodec 方法移除了，默认就是utf8，不需要设置。

26. qcombobox 的 activated(QString) 和 currentIndexChanged(QString) 信号删除了，用int索引参数的那个，然后自己通过索引获取值。个人觉得这个没必要删除。

27. qtscript模块彻底没有了，尽管从Qt5时代的后期版本就提示为废弃模块，一致坚持到Qt6才正式废弃，各种json数据解析全部换成qjson类解析。

28. QByteArray 的 append indexOf lastIndexOf 等众多方法的QString参数重载函数废弃了，要直接传 QByteArray，就在原来参数基础上加上 .toUtf8() 。查看源码也看得到以前的QString参数也是转成.toUtf8()再去比较。

29. QDateTime的时间转换函数 toTime_t + setTime_t 名字改了，对应改成了 toSecsSinceEpoch + setSecsSinceEpoch ，这两个方法在Qt5.8时候新增加的。

30. QLabel的 pixmap 函数之前是指针 *pixmap() 现在换成了引用 pixmap()。

### 04：31-40
31. QTableWidget的 sortByColumn 方法移除了默认升序的方法，必须要填入第二个参数表示升序还是降序。

32. qtnetwork模块中（TCP/UDP相关的socket）的错误信号error换成了errorOccurred，就改了个名字，注意websocket那块居然没统一改过来依然是叫error。
```cpp
#if (QT_VERSION >= QT_VERSION_CHECK(6,0,0))
    connect(udpSocket, SIGNAL(errorOccurred(QAbstractSocket::SocketError)), this, SLOT(error()));
    connect(tcpSocket, SIGNAL(errorOccurred(QAbstractSocket::SocketError)), this, SLOT(error()));
#else
    connect(udpSocket, SIGNAL(error(QAbstractSocket::SocketError)), this, SLOT(error()));
    connect(tcpSocket, SIGNAL(error(QAbstractSocket::SocketError)), this, SLOT(error()));
#endif

//特别注意websocket中依然还是用error
connect(webSocket, SIGNAL(error(QAbstractSocket::SocketError)), this, SLOT(error()));
```

33. XmlPatterns模块木有了，全部用xml模块重新解析。

34. nativeEvent的参数类型变了。
```cpp
#if (QT_VERSION >= QT_VERSION_CHECK(6,0,0))
bool nativeEvent(const QByteArray &eventType, void *message, qintptr *result);
#else
bool nativeEvent(const QByteArray &eventType, void *message, long *result);
#endif
```

35. QButtonGroup的buttonClicked信号中int参数的函数全部改名字叫idClicked。
```cpp
    QButtonGroup *btnGroup = new QButtonGroup(this);
#if (QT_VERSION >= QT_VERSION_CHECK(6,0,0))
    connect(btnGroup, SIGNAL(idClicked(int)), ui->xstackWidget, SLOT(setCurrentIndex(int)));
#else
    connect(btnGroup, SIGNAL(buttonClicked(int)), ui->xstackWidget, SLOT(setCurrentIndex(int)));
#endif
```

36. QWebEngineSettings之前是QWebEngineSettings::defaultSettings();现在改成了QWebEngineProfile::defaultProfile()->settings();通过查看之前的源码得知QWebEngineSettings::defaultSettings();封装的就是QWebEngineProfile::defaultProfile()->settings();因为Qt6去除了N多过度封装的函数。
```cpp
#if (QT_VERSION >= QT_VERSION_CHECK(6,0,0))
    QWebEngineSettings *webSetting = QWebEngineProfile::defaultProfile()->settings();
#else
    QWebEngineSettings *webSetting = QWebEngineSettings::defaultSettings();
#endif
```

37. Qt6将enterEvent的参数QEvent改成了QEnterEvent也不打个招呼。这种改变编译也不会提示的。
```cpp
#if (QT_VERSION >= QT_VERSION_CHECK(6,0,0))
    void enterEvent(QEnterEvent *);
#else
    void enterEvent(QEvent *);
#endif

//后面经过JasonWong大佬的指点，从父类重新实现的virtual修饰的函数，建议都加上override关键字。
//这样的话一旦父类的函数或者参数变了则会提示编译报错，而不是编译通过但是运行不正常会一脸懵逼茫然，从而把锅扣给Qt。

//下面是父类函数
virtual void enterEvent(QEvent *event);
//子类建议加上override
void enterEvent(QEvent *event) override;
```

38. Qt6中多个类进行了合并，比如现在QVector就成了QList的别名，意味着这两个类是同一个类没有任何区别，可能Qt内部对两种的优点都集中在一起，并尽量重写算法或者其他处理规避缺点。同理QStringList现在也成了 QList<QString> 的别名，是同一个类，没有单独的类。

39. 在Qt4时代默认QWidget构造函数父类是0，到了Qt5变成了Q_NULLPTR，到了Qt6居然用的是默认的c++标准中的nullptr而不是Qt自定义定义的Q_NULLPTR（同样的还有Q_DECL_OVERRIDE换成了用override等），可能是为了彻底抛弃历史包袱拥抱未来。
```cpp
//下面依次是Qt4/5/6的写法
MainWindow(QWidget *parent = 0);
MainWindow(QWidget *parent = Q_NULLPTR);
MainWindow(QWidget *parent = nullptr);

//查阅Qt源码查看Q_NULLPTR原来是根据编译器定义来选择
#ifdef Q_COMPILER_NULLPTR
# define Q_NULLPTR         nullptr
#else
# define Q_NULLPTR         NULL
#endif

//Qt高版本兼容低版本写法比如Qt5/6都支持 *parent = 0 这种写法。
```

40. 对于委托的进度条样式QStyleOptionProgressBar类的属性，在Qt4的时候不能设置横向还是垂直样式，默认横向样式，要设置orientation需要用另外的QStyleOptionProgressBarV2。从Qt5开始新增了orientation和bottomToTop属性设置。在Qt6的时候彻底移除了orientation属性，只有bottomToTop属性，而且默认进度是垂直的，很操蛋，理论上默认应该是横向的才对，绝大部分进度条场景都是横向的。这个时候怎么办呢，原来现在的处理逻辑改了，默认垂直的，如果要设置横向的直接设置 styleOption.state |= QStyle::State_Horizontal 这种方式设置才行，而Qt6以前默认方向是通过 orientation 值取得，这个State_Horizontal从Qt4就一直有，Qt6以后要主动设置下才是横向的就是。

### 05：41-50
41. Qt6.2版本开始增加了对多媒体模块的支持，但是在mingw编译器下还是有问题，直到6.2.2才修复这个问题，官网解释是因为mingw编译器版本不支持，到6.2.2采用了新的mingw900_64，这个编译器版本才支持。所以理论上推荐从6.2.2开始使用新的Qt6。

42. QTextStream中的setCodec方法改成了setEncoding，参数变了，功能更强大。
```cpp
QTextStream stream(&file);
#if (QT_VERSION < QT_VERSION_CHECK(6,0,0))
stream.setCodec("utf-8");
stream.setCodec("gbk");
#else
stream.setEncoding(QStringConverter::Utf8);
stream.setEncoding(QStringConverter::System);
#endif
```

43. QModelIndex的查找子节点child函数去掉了，但是查找父节点parent函数保留，查阅代码得知之前的child函数就是封装的model->index(row, column, QModelIndex)函数。
```cpp
//下面两个函数等价 如果要兼容Qt456则用下面这个方法
QModelIndex index = indexParent.child(i, 0);
QModelIndex index = model->index(i, 0, indexParent);

//下面两个函数等价 如果要兼容Qt456则用下面这个方法
QModelIndex indexChild = index.child(i, 0);
QModelIndex indexChild = model->index(i, 0, index);
```

44. 之前QPixmap类中的静态函数grabWindow和grabWidget彻底废弃了，改成了用QApplication::primaryScreen()->grabWindow，其实这个从Qt5开始就建议用这个。
```cpp
#if (QT_VERSION >= QT_VERSION_CHECK(5,0,0))
    QPixmap pixmap = QApplication::primaryScreen()->grabWindow(widget->winId());
#else
    QPixmap pixmap = QPixmap::grabWidget(widget->winId());
#endif
```

45. QProcess中的start方法以前直接支持传入完整的命令，到了Qt6严格要求必须拆分后面的参数。
```cpp
//Qt6以前支持执行完整命令
QProcess p;
p.start("wmic cpu get Name");
//Qt6需要改成下面的方法，此方法也兼容Qt4、5、6
p.start("wmic", QStringList() << "cpu" << "get" << "Name");
```

46. 在qss中对属性的枚举值写法到了Qt6换成了数值表示（需要翻阅枚举值的定义找到对应的值），这个改动挺大，切记需要切换过来，而且这种写法不兼容Qt5。
```cpp
//Qt4/5 通过样式表设置标签右上角对齐
ui->label->setStyleSheet("qproperty-alignment:AlignRight;");
//Qt4/5 通过样式表设置标签居中对齐
ui->label->setStyleSheet("qproperty-alignment:AlignHCenter|AlignVCenter;");

//Qt6 通过样式表设置标签右上角对齐 翻阅 AlignRight 的枚举值=2
ui->label->setStyleSheet("qproperty-alignment:2;");
//Qt6 通过样式表设置标签居中对齐 翻阅 AlignHCenter|AlignVCenter 的枚举值=0x04|0x80=0x84=132
ui->label->setStyleSheet("qproperty-alignment:132;");
```

47. Qt6中多媒体模块的类做了巨大调整改动，有些是类名的变化，比如音频输出（也叫播放）之前是 QAudioOutput 现在是 QAudioSink ，音频输入（也叫录音）之前是 QAudioInput 现在是 QAudioSource ，默认音频输入输出设备集合之前是 QAudioDeviceInfo::defaultInputDevice()、QAudioDeviceInfo::defaultOutputDevice()，现在是 QMediaDevices::defaultAudioInput()、QMediaDevices::defaultAudioOutput()。感觉这个名字改的没有以前贴切。
```cpp
#if (QT_VERSION >= QT_VERSION_CHECK(6,2,0))
#define AudioInput QAudioSource
#define AudioOutput QAudioSink
#else
#define AudioInput QAudioInput
#define AudioOutput QAudioOutput
#endif
//使用的时候只需要new就行
AudioInput *input = new AudioInput(format, this);

#if (QT_VERSION >= QT_VERSION_CHECK(6,2,0))
#define QAudioInput QAudioSource
#define QAudioOutput QAudioSink
#endif
//使用的时候只需要new就行
QAudioInput *input = new QAudioInput(format, this);
```

48. Qt6开始默认用cmake，所以现在新版的qtcreator在新建项目的时候默认选择的就是cmake，很多初学者首次用的时候会发现，怎么突然之间生成的项目，结构都不一样，突然之间懵逼了，所以要在新建项目的过程中选择qmake，选择一次以后就默认qmake了。

49. Qt6.4开始对应类QString/QByteArray的count函数废弃了，改用size/length函数，估计可能描述更准确吧。

50. Qt6.4.1新增了N多BUG，强烈不建议使用，比如QAudioSink播放声音没有声音 [https://bugreports.qt.io/browse/QTBUG-108383](https://bugreports.qt.io/browse/QTBUG-108383)，DPI缩放严重变形 [https://bugreports.qt.io/browse/QTBUG-108593](https://bugreports.qt.io/browse/QTBUG-108593)。这些BUG在6.4.0/6.5.0是不存在的，KPI害死人啊。

51. Qt6.5版本开始取消了QVariant的默认构造函数，之前return QVariant() 现在必须改成 QVariant(QVariant::Invalid) 才不会有警告提示。通过打印值发现QVariant()本身就=QVariant(QVariant::Invalid)，所以统一写成QVariant(QVariant::Invalid)兼容Qt456。