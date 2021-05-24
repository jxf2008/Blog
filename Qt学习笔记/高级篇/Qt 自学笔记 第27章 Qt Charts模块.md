## 关于Qt Charts模块

在22-25章中讲述了如何在GUI程序里显示数据，前面说过，数据的显示可以大致分为图表和图像两种方式，前面的几章使用了Qt提供的模型/视图结构，通过表格（一维表，二维表，树形表等等）的形式来显示数据，而接下来将通过图像来向用户显示数据。

使用图像来表示数据最大的好处就是直观，这方面的内容现在有个比较流行的词汇“数据可视化”。Qt对于“数据可视化”提供了QtCharts模块来实现，该模块在前面的章节中有提到，而这里将详细的讲解下这个模块。

在正式开始前，有几个问题需要说明下，首先，QtCharts模块以前属于付费使用，直到Qt5.7版本才变为免费使用，所以如果你的Qt版本低于5.7，理论上需要付费才能使用该模块。其次，在5.7以上的版本，该模块已经免费，但安装时默认不安装该模块，所以请确保你的Qt已经安装了该模块。最后，该模块内容非常多，这里只能做部分介绍。

## 饼状图

这一章先利用24和25章的示例程序PatientRecord介绍一个简单的饼状图。在演示程序PatientRecord中，在表格年龄这一列中，我们使用颜色来区别不同的年龄段，这样可以提示医生在输入年龄的时候可能出现的错误，这样尽可能的减少出错的可能性。但或许可以用另一种更加直观发方式来显示这个问题，比如下图这样

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/QtNotes/27-1.png)

我们在程序的右侧添加了一个窗体，这个窗体是一个圆形图标，他显示的是左侧表格年龄段分布比例，对比下，左侧的年龄字段里颜色有可能没看清楚，但右侧分布图里很清楚的显示里这里存在有可能错误的颜色（红色）。而右侧的这个窗体正是使用QtCharts模块来完成的。

接下来我们来看下代码，要完成这个功能需要修改前一章程序里的PatientRecord类文件。

PS:希望你没把PatientRecord的代码弄丢了。为了区别，这里贴出了h文件的全部代码，可以和前一章的内容做下对比
```c++
#include <QDialog>
#include <QPushButton>
#include <QTableView>
#include <QtCharts/QPieSeries>   //注释1
#include <QtCharts/QPieSlice>
#include <QtCharts/QChart>
#include <QtCharts/QChartView>
#include "PatientInfoModel.h"
#include "PatientAgeDelegate.h"
#include "PatientDateDelegate.h"

class PatientRecord : public QDialog{
    Q_OBJECT
private:
    QPushButton* pageUp_PushButton;
    QPushButton* pageDown_PushButton;

    QTableView* info_TableView;

    PatientInfoModel* info_Model;

    QtCharts::QPieSeries* age_PieSeries;
    QtCharts::QChart* age_Chart;
    QtCharts::QChartView* ageView_ChartView;  //注释2
public:
    PatientRecord(QWidget *parent = nullptr);
    ~PatientRecord();
private slots:
    void pageUp();
    void pageDown();
    void createAllPieView();       //注释3
};
```
+ 注释1 这里包含了一些需要使用的Qt Charts模块的类，如果需要使用该模块，需要在.pro文件里添加
```shell
QT += charts
```
如果你使用的是vs编译器，需要在add QT->设置->模块 里勾选QtCharts模块。

+ 注释2 Qt Charts模块相关的类，常量等均位于名称空间QtCharts内。

+ 注释3 该函数用于显示示例程序右侧的饼状图，而我们看见的右侧的饼状图实际上就是ageView_ChartView。

在头文件中出现了3个新的类成员，而他们是构成饼状图的核心，先看下他们在构造函数中的创建
```c++
    ageView_ChartView = new QtCharts::QChartView();
    age_PieSeries = new QtCharts::QPieSeries();
    age_Chart = new QtCharts::QChart();
    ageView_ChartView->setChart(age_Chart);
    age_Chart->addSeries(age_PieSeries);
    age_Chart->setTitle(tr("Age Distribution"));
    //age_Chart->legend()->hide();
```
其实Qt Charts模块和17-19章讲述的QGraphicsXXXX模块非常相似，QtCharts::QChartView相当于QGraphicsView用于显示，也只有这个窗体需要通过布局管理器安装到程序界面上，而实际上QtCharts::QChartView就是QGraphicsView的一个子类。而QtCharts::QChart则类似于QGraphiccSence,QtCharts::QPieSeries和QtCharts::QPieSlice则相当于QGraphicsItem。当然，马上要看到QtCharts模块和QGraphicsXXXXX模块的结构也有显著的不同。

接下来看下比较核心的createAllPieView()函数
```c++
void PatientRecord::createAllPieView(){
    QList<int> ages = info_Model->getAllAge();
    int blacks = 0;
    int greens = 0;
    int reds = 0;      //注释3
    for(auto A : ages){
        if(A >= 18 && A <= 35) ++blacks;
        else if (A < 13 || A > 55) ++greens;
        else ++reds;
    }

    age_PieSeries->clear();
    age_PieSeries->append(tr("18-35"),blacks);  //注释4
    age_PieSeries->append(tr("13-18 35-55"),greens);
    age_PieSeries->append(tr("55+ 13-"),reds);

    age_PieSeries->slices().at(0)->setBrush(QBrush(Qt::black));  //注释5
    age_PieSeries->slices().at(1)->setBrush(QBrush(Qt::green));

    QtCharts::QPieSlice* age_PieSlice = age_PieSeries->slices().at(2);
    age_PieSlice->setExploded();   
    age_PieSlice->setLabelVisible();  
    age_PieSlice->setBrush(QBrush(Qt::red));
    age_PieSlice->setPen(QPen(QColor(Qt::blue)));  //注释6
}
```
+ 注释4 这里对之前的自定义模型做了小小的修改，添加了一个可以返回当前页面10个年龄的函数，即getAllAge(),在获得年龄后对其进行分类，黑色，绿色和红色分表表示对应年龄段的患者数量

+ 注释5 对于饼状图，可以分成两个部分，一个QPieSeries可以理解为一个披萨盘，而披萨盘上可以放置任意份披萨（既QPieSlice），而制作的顺序也非常简单，先生产一个盘子（QPieSeries），然后通过append()函数往盘子上添加披萨（QPieSlice），append()函数的第一个参数可以对照示例图片，看下这些文字出现的位置以及方式，第二个参数可以理解为百分比。

+ 注释6 在添加完披萨（QPieSlice）之后，可能需要对其中的一个或几个做特别的处理，QPieSeries的at()函数返回一个指向QPieSlice的指针，可以通过该指针来进行进一步的操作。例如在这个示例中，setExploded()用于让这块披萨能够突出显示。setLabelVisible()用于是的标签文本可见，该文本就是append()的第一个参数，默认作为标签文本时时不可见的，这里也可以看出append()函数的第一个参数会出现在2个位置，出现在标题默认可见，而出现在标签默认不开见。最后在设置这块披萨（QPieSlice）的背景颜色和边框颜色

从上面的代码，可以看出Qt Charts的结构和GraphicsXXXXX的不同。以这个柱状图为例，他使用QPieSlice和QPieSeries结合来生产饼状图，而如果要清楚饼状图，调用QPieSeries的clear()函数即可，当然也可以通过QCharts的removeAllSeries()来移除所有的QPieSeries来达到删除现有饼状图的目的，简单的说，Qt Charts模块主要分为4个层次

1. QChartView,用于显示的窗体

2. QChart,用于管理各种项，标题等等，同时配合QchartView将这些项显示出来，QChart继承自QGraphicsWidget。

3. AbstractSeries的子类（如示例中的QPieSeries）被称为项。项可以移除构成他的全部部件，这样他就可以重新添加部件变成新的项了。

4. 每很多项都有各自的部件（如示例中的QPieSlice）组成，但也有些项没有部件。

>这里的“项”是我为了描述问题方便临时发明的词汇，我实在不知道标准的中文翻译叫什么

将二维数据（表格）转化为图标是一项非常常见的工作，根据不同的需求，可以通过不同的图标来表示二维数据，Qt就自带了一个例子，用柱状图来表示和对比二维数据，有兴趣的可以在Qt Creator的“示例”中搜索“BarModelMapper”，运行示例“BarModelMapper Example”。

## 线形图

首先说明下，线形图和上面的饼状图一样是我临时起的名字用于方便描述问题，准确的翻译可能不是这个。

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/QtNotes/27-2.png)

在图表中，线形同样是个非常常见的图表，类似下面这样,要实现这样一个示例非常简单，需要用到Qt Charts模块的QSplineSeries类，这个类类似于上面的QPieSeries，不同的是QSplineSeries并没有自己的部件
```c++
QT_CHARTS_USE_NAMESPACE     //注释7

QSplineSeries *series = new QSplineSeries();
series->setName("spline");

series->append(0, 6);    //注释8
series->append(2, 4);
series->append(3, 8);
series->append(7, 4);
series->append(10, 5);
*series << QPointF(11, 1) << QPointF(13, 3) << QPointF(17, 6) << QPointF(18, 3) << QPointF(20, 2);

QChart *chart = new QChart();
chart->legend()->hide();
chart->addSeries(series);
chart->setTitle("Simple spline chart example");
chart->createDefaultAxes();                //注释9
chart->axes(Qt::Vertical).first()->setRange(0, 10);     //注释10

QChartView *chartView = new QChartView(chart);
chartView->setRenderHint(QPainter::Antialiasing);
```
+ 注释7 这段示例代码直接复制自Qt自带的示例“splinechart”,Qt的示例代码使用了名称空间，我一般不用using namespace XXX,因为不同库有点代码可能会用冲突。

+ 注释8 这里演示了添加点的两种方式

+ 注释9 添加一个默认的坐标系，和前面的饼状图不同，线形图需要X和Y轴的坐标系。大多数情况下，默认的坐标可以满足需求，如果一些特殊的图标需要使用特殊的坐标系，可以继承QAbstractAxis实现一个自定义坐标系然后通过addAxis()来添加坐标系。添加坐标系，无论自定义的还是使用默认，都必须在addSeries()后使用。

+ 注释10 这里演示了如何获取坐标系并对其进行进一步的设置