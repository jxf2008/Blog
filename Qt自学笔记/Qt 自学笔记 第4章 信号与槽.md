## 信号与槽

还记得第一章的Hello Qt程序吗，不知道你有没有用QPushButton来代替QLabel来重新实现这个程序，因为这一章需要用到这个

在正式讨论信号与槽之前，我们先简单的讨论一个问题，在界面中，有很多结束/关闭的选项，点击一下程序就结束了，在Qt中，也有类似的情况，比如我点击一个按钮，整个程序就结束了，放在代码的角度来说，有一个类，当我执行他的一个成员函数（点击了这个按钮），另一个类（整个窗体）就要执行对应的某个成员函数，那如何把这两个类的成员函数链接在一起呢，确保执行了一个函数后另一个函数也会被执行？对于c++来说，这类问题一般需要用到函数回调这类技术，而在很多时候，即使使用函数回调也会非常的费力。为了解决类似的问题，Qt提供了信号与槽的概念用于来实现这类功能，当然熟悉UNIX/Linux的朋友也了解信号这个概念，但需要说明的是Qt的信号和UNIX/Linux的信号没有任何关系

以QPushButton为例，当点击他的时候就会出发clicked()信号，这个信号可以用来和对应的槽来连接，当没有与槽连接时，这个信号没有任何作用。碰巧的是QPushButton自身也有一个槽close(),这个槽的作用就是关闭自身，所以我们可以做一个按钮，点击他就会自己关闭，而不是点就右上角的"X"。为了演示这个问题，对前一章的代码稍作修改。
```c++
#include<QApplication>
#include<QPushButton>
int main(int argc , char** argv)
{
  QApplication app(argc,argv);
  QPushButton* quit_Pushbutton = new QPushButton("Quit");
  quit_Pushbutton->show();
  QObject::connect(quit_Pushbutton,SIGNAL(clicked()),quit_Pushbutton,SLOT(close()));
  return app.exec();
}
```
这段代码和第一章Hello Qt代码相比多了一行，就是信号与槽的链接，链接使用类QObject的静态函数connect()来完成，这个函数看起来有点复杂，但其参数其实很简单
```
connect(信号对象指针，SIGNAL(信号函数），槽对象指针，SLOT(槽函数));
```
这样我们就完成了一个信号和槽的连接，当点击按钮是按钮发出clicked()信号，接受这个信号的槽（函数），也就是close()也被触发（执行），于是这个按钮就被关闭了。

## 应用

然后我们来看一个稍显复杂的例子

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/QtNotes/4-1.png)

这个程序用于显示年龄，在一个对话框里安装了2个窗体，一个“显示块”，一个“划杆”，当然他们确切的名字分别是QSpinBox和QSlider，在这个程序中，拖动划块，“显示块”对于的数值就会改变，同样，修改“显示块”的值也会是的“划杆”的值改变。这里就用到了信号与槽的连接，当QSpinBox数值改变，出发一个信号，这个信号与QSlider的槽连接，这个槽作用就是改变自身的值。同样的QSlider的值改变是也会出发一个信号，这个信号同样的和QSpinBox的槽连接。当然这里我们还需要面对一个问题，那就是信号与槽直接除连接外，还需要传输数据。
```c++
#include<QApplication>
#include<QDialog>
#include<QSpinBox>
#include<QSlider>
#include<QHBoxLayout>
int main(int argc , char** argv)
{
  QApplication app(argc,argv);
 
  QDialog* top_Dialog = new QDialog;
  QSpinBox* box_Spinbox = new QSpinBox;
  QSlider* box_Slider = new QSlider(Qt::Horizontal); //注释1
 
  box_Spinbox->setRange(0,130);   //注释2
  box_Slider->setRange(0,130);
 
  QObject::connect(box_Spinbox,SIGNAL(valueChanged(int)),box_Slider,SLOT(setValue(int)));  //注释3
  QObject::connect(box_Slider,SIGNAL(valueChanged(int)),box_Spinbox,SLOT(setValue(int)));
  box_spinbox->setValue(30);  //注释4
 
  QHBoxLayout* top_Layout = new QHBoxLayout;
  top_Layout->addWidget(box_Spinbox);
  top_Layout->addWidget(box_Slider);
 
  top_Dialog->setLayout(top_Layout);
  top_Dialog->setWindowTitle("Show Your Age");
  top_Dialog->show();
 
  return app.exec();
}
```
+ 注释1 这里生产了我们需要的3个窗体，分别是QDialog,QSpinBox和QSlider，这里需要说明的是QSlider的构造函数有个默认的参数，是一个枚举量，取值分别为Qt::Horzental和Qt::Vertical,其默认值为Qt::Vertical,有兴趣的可以使用默认值在编译下这个程序

+ 注释2  这里设置2个窗体显示数值的范围，暂且假设人最大的年龄不会超过130岁

+ 注释3 这里是整个程序的核心代码，QSpinBox和QSlider都有一个valueChanged(int)的信号，当他们的值改变的时候会发射，他们也都有一个槽setValue(int)，用于改变自身的值，这里也说明了，信号如何把数据传递给槽的，所以不同窗体（类）直接的数据传输也可以用信号与槽来实现，这种方式在后面的例子中将会不断的用到。

+ 注释4 这里给定一个初始值，由于已经连接了信号与槽，所以设定一个窗体的值，另一个窗体的值也会改变，不需要而外设置，另外你也可以把这行代码移动到注释3上面看看效果

## 一些细则

1. 同一个信号可以和多个槽连接，一个槽也可以与多个信号链接。同时信号也可以与信号连接，类似
```c++
connect(对象A，SIGNAL(clicked()),对象B，SIGNAL(customSignal()));
```
这种情况通常用于多个信号需要同时发射,不过在这种情况下，clicked()和customSignal()这两个信号发射的先后顺序是随机的

2. 对于通过信号与槽传递参数，信号函数和槽函数的参数必须一致，如果有这样的连接
```c++
connect(对象A，SIGNAL(valueChange(QString,int)),对象B，SLOT(valueChanged(int,QString)));
```
那槽将无法接受到任何数据，如果槽函数的参数有默认值将会使用默认值，如果没有就会出错，而对于下面这样的连接
```c++
connect(对象A，SIGNAL(valueChange(QString,int)),对象B，SLOT(valueChanged(QString)));
```
不会出现错误，但信号中int数据将无法传递到槽函数中。

Qt的信号与槽机制，对于参数类型判断非常严格。例如const QString&和QString&就被认为是两种参数。还有种比较特殊的情况，假设类A内定义了一个枚举;
```c++
class A
{
public:
    enum ChessType{BlackChess,WhiteChess,EmptyChess};
signals:
    void changeType(ChessType tp);
public slots:
    void resetChess(A::ChessType tp);
}
```
从c++角度来说，函数的参数A::ChessType和ChessType是一个东西，但如果你把信号与槽连接的话
```c++
connect(this,SIGNAL(changeType(ChessType)),this,SLOT(resetChess(A::ChessType)));
```
这个连接时无法正常工作的，因为在Qt的信号与槽机制中，A::ChessType和ChessType是两个不同类型的参数。

3. 信号与槽其实就是类的成员函数，所不同的是信号函数一般只有函数声明还没有函数定义，而槽函数有函数定义来实现具体的功能  ，当然这样只是表明现象，其实信号函数之所以没有代码，是Qt已经做了一些处理，而并非真正的没有代码。而槽函数可以和成员函数一样调用。

4. 本章上面的连接信号与槽的例子都是采用Qt一直以来的格式，而如果你查看Qt的文档会发现，Qt文档里都采用下面的格式。
```c++
connect(box_Spinbox,&QSpinBox::valueChanged,box_Slider,&QSlider::setValue);
```
这时候Qt5开始采用的语法，但我个人很不喜欢这样的写法，因为读代码的时候不知道信号与槽的参数到底是什么，需要跳转到信号或槽的定义去查看，所以我一直习惯老的格式。



