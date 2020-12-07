## 记事本

对于大多数window7/10等win用户来说，windows自带的记事本程序再熟悉不过了，他提供了最基本的文本编辑功能，接下来几章我们将制作一个类似的程序，在<Qt4 C++ GUI编程>中，到这里应该介绍一个制表程序，但那个程序对于新手来说，太复杂了。特别他用到了很多后面章节的内容，实际上直到现在，如果要我完成这样一个程序时都需要花费不小的精力。所以我决定用一个记事本程序来代替他作为讲解内容，我仔细对比了下制表程序和记事本这两个例子，实际上并不影响对Qt功能的介绍，个人建议有一定Qt编程基础的人可以尝试下去完成那个制表程序，如果是初学者，还是建议跟着我的笔记先制作一个相对简单的记事本。

整个程序相对（之前几章的例子）比较大，所以我们先从他的一个对话框开始。

## 查询对话框

首先，他的界面是这个样子的

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/QtNotes/5-1.png)

这个对话框和windows记事本的对话框很相似，这个对话框中除了前面章节已经介绍过的QLabel和QPushButton外，还使用了

>QLineEdit 这是一个基于行的文本编辑器，提供了基础的文本编辑功能

>QCheckBox 这个是单选框，功能和他的名字一样。

>QDialog 对话框在图像编程中最常见的窗体，很多程序都会利用对话框和用户进行信息交互，在QT中，大多数对话框都会继承自QDialog.

要完成这个对话框的制作，我们首先分两步，第一步，制作界面布局，第二步，实现他的功能

这个对话框被暂时命名为FindDialog,首先是他的头文件代码

```c++
#include <QDialog>  //注释1
#include <QLineEdit>
#include <QCheckBox>
#include <QPushButton>
#include <QLabel>

class FindDialog:public QDialog
{
private:
    QLabel* title_Label;
    QLineEdit* findString_LineEdit;
    QPushButton* find_PushButton;
    QPushButton* close_PushButton;
    QCheckBox* matchCase_CheckBox;
    QCheckBox* goBack_CheckBox;
public:
    FindDialog(QWidget* parents = nullptr);  //注释2
};
```

+ 注释1  这里包含了各控件所需要的头文件，其中QDialog是作为QFindDialog的基类

+ 注释2 这是构造函数，参数是一个QWidget的指针，前面说过Qt中窗体部件都会继承自QWidget，这个参数默作用是设置这个窗体的父窗体，如果值使用默认值，就说明该窗体没有父窗体。

然后是FindDialog.cxx文件

```c++
#include <QHBoxLayout>
#include <QVBoxLayout>
#include "FindDialog.h"

FindDialog::FindDialog(QWidget* parents):QDialog(parents) //注释3
{
    title_Label = new QLabel(tr("查询内容"));  //注释4
    findString_LineEdit = new QLineEdit;
    find_PushButton = new QPushButton(tr("查询"));
    close_PushButton = new QPushButton(tr("取消"));
    matchCase_CheckBox = new QCheckBox(tr("区分大小写"));
    goBack_CheckBox = new QCheckBox(tr("向后查询"));
 
    QHBoxLayout* string_Layout = new QHBoxLayout;  //注释5
    string_Layout->addWidget(title_Label);
    string_Layout->addWidget(findString_LineEdit);
    QVBoxLayout* case_Layout = new QVBoxLayout;
    case_Layout->addLayout(string_Layout);
    case_Layout->addWidget(matchCase_CheckBox);
    case_Layout->addWidget(goBack_CheckBox);
    QVBoxLayout* pushButton_Layout = new QVBoxLayout;
    pushButton_Layout->addWidget(find_PushButton);
    pushButton_Layout->addWidget(close_PushButton);
    pushButton_Layout->addStretch();
    QHBoxLayout* main_Layout = new QHBoxLayout;
    main_Layout->addLayout(case_Layout);
    main_Layout->addLayout(pushButton_Layout);
    setLayout(main_Layout);
    main_Layout->setSizeConstraint(QLayout::SetFixedSize);  //注释6
 
 
    find_PushButton->setDefault(true); //注释7
    find_PushButton->setEnabled(false);
  
  setWindowTitle(tr("查询"));
}
```
+ 注释3 在构造函数中调用基类的构造函数，参数parent的类型是QWidget*,传递的参数只要是继承自QWidget的窗体都可以作为参数，即这个窗体的父窗体。参考C++中公有继承的is-a关系

+ 注释4 创建我们需要的各个窗体部件,这些创图由于会通过布局管理器安装到父窗体（FindDialog）上，所以没必要在构造函数里显示的声明父窗体了。

+ 注释5 使用布局管理器来安装各个窗体部件，代码比较多但其实就是布局管理器的各种嵌套，具体步骤：

1. 把QLabel和QLineEdit放入一个QHBoxLayout（既string_Layout)

2. 把上面的string_Layout和两个QCheckBox放入一个QVBoxLayout(即case_Layout)

3. 把2个QPushButton放入一个QVBoxLayout(即pushButton_Layout),然后在下面价格弹簧addStretch()

4. 把case_Layout和pushButton_Layout放入一个QHBoxLayout(即main_Layout)
当然就像前面布局一章中演示的那样，你也可以尝试用其他的嵌套来完成这个界面布局

+ 注释6 这个函数的作用是限定对话框的大小，对于Qt各窗体部件，如果你没有设置他大小的情况下，都会有一个Qt认为最合适的大小，事实上这个大小大多数情况下都符合我们的要求，所以用这个函数使得对话框的大小固定为默认值，即Qt认为最适合的值，这个函数通常用于窗体需要禁止拉伸的情况下

+ 注释7 这里调用了几个窗体的成员函数
setDefault()函数，用于设置这个按钮为默认按钮，默认按钮的意义在于，当你的当前窗体为对话框的时候，按下回车建，程序将认为你点击了该按钮
setEnabled()函数，设置查询按钮不可用，当QLineEdit里的内容为空的时候，该按钮不可用

最后我们要调用这个FindDialog类,来生成一个具体的对象，我们可以编写一个简单的Main.cxx来实现
```c++
#include <QApplication>
#include "FindDialog.h"

int main(int argc , char** argv)
{
    QApplication app(argc,argv);
    FindDialog A;
    A.show();
    app.exec();
}
```
注意这里使用了FindDialog A而不是FindDialog* A = new FindDialog。至于为什么这里不使用new，后面的内存章节会解释，再此之前的章节里，暂时忽略内存的问题，这里new一下也行，你的电脑因此死机的概率并不大。

## 功能实现

现在我们完成了第一步，界面的制作，然后我们需要实现他的具体功能

我们先要添加2个功能，第一，点击取消按钮的时候，这个对话框能够关闭，第二，当QLineEdit里有内容的时候,查询按钮可用，需要实现这2个功能，需要用到信号与槽

首先看下FindDialog.h文件的改动
```c++
#include <QDialog>
#include <QLineEdit>
#include <QCheckBox>
#include <QPushButton>
#include <QLabel>

class FindDialog:public QDialog
{
Q_OBJECT   //注释8
private:
    QLabel* title_Label;
    QLineEdit* findString_LineEdit;
    QPushButton* find_PushButton;
    QPushButton* close_PushButton;
    QCheckBox* matchCase_CheckBox;
    QCheckBox* goBack_CheckBox;
public:
    FindDialog(QWidget* parents = 0);
public slots:
    void findIsEnabled(const QString& str);  //注释9
};
```
+ 注释8 这里添加了一行Q_OBJECT,这是一个Qt定义的宏，如果一个类需要使用信号与槽，就必须添加这个宏,而且这个宏必须位于类声明的第一行。

+ 注释9  这里添加了一个公有槽，用于设置查询按钮是否可用，这里注意的是槽有私有和公有的区别，共有槽在类外也可以链接（使用），而私有槽只能用于类的内部，这个和私有/公有成员函数是一致的  
  
然后在看下FindDialog.cxx文件的改动,这里放出完整代码，方便对比
```c++
#include <QHBoxLayout>
#include <QVBoxLayout>
#include "FindDialog.h"

FindDialog::FindDialog(QWidget* parents):QDialog(parents)
{
    title_Label = new QLabel("查询内容");
    findString_LineEdit = new QLineEdit;
    find_PushButton = new QPushButton("查询");
    close_PushButton = new QPushButton("取消");
    matchCase_CheckBox = new QCheckBox("区分大小写");
    goBack_CheckBox = new QCheckBox("向后查询");
 
    QHBoxLayout* string_Layout = new QHBoxLayout;
    string_Layout->addWidget(title_Label);
    string_Layout->addWidget(findString_LineEdit);
    QVBoxLayout* case_Layout = new QVBoxLayout;
    case_Layout->addLayout(string_Layout);
    case_Layout->addWidget(matchCase_CheckBox);
    case_Layout->addWidget(goBack_CheckBox);
    QVBoxLayout* pushButton_Layout = new QVBoxLayout;
    pushButton_Layout->addWidget(find_PushButton);
    pushButton_Layout->addWidget(close_PushButton);
    pushButton_Layout->addStretch();
    QHBoxLayout* main_Layout = new QHBoxLayout;
    main_Layout->addLayout(case_Layout);
    main_Layout->addLayout(pushButton_Layout);
    setLayout(main_Layout);
    main_Layout->setSizeConstraint(QLayout::SetFixedSize);
 
    find_PushButton->setDefault(true);
    find_PushButton->setEnabled(false);
  
    connect(findString_LineEdit,SIGNAL(textChanged(const QString&)),
    this,SLOT(findIsEnabled(const QString&)));
    connect(close_PushButton,SIGNAL(clicked()),this,SLOT(close()));   //注释10
 
    setWindowTitle("查询");
}

void FindDialog::findIsEnabled(const QString& str)   //注释11
{
    find_PushButton->setEnabled(!str.isEmpty());
}
```

+ 注释10  这里进行了2个链接，点击关闭按钮，触发clicked()信号，链接到这个类（对话框）的close()槽，这个FindDialog类继承自QDialog,close()是QDialog的一个公有槽，用于关闭自身。对于QLineEdit，有一个信号textChanged(const QString&),每当编辑行的内容发生改变的时候就会发射这个信号，我们在FindDialog中自定义了一个公有槽，和这个信号链接

+ 注释11  这是自定义的公有槽，当然，这个函数也完全可以当初普通的公有成员函数来使用，信号会把编辑行的内容以QString的形式传递过来，通过判断QString是否为空就可以设置查询按钮是否可用 

我们运行这个程序后可以实现2个功能，第一，往编辑行里面写一些东西，查询按钮就会变为可用，删除掉编辑行里的内查询按钮又会便的不可用，第二，点击取消按钮的时候这个窗体会关闭，即程序结束

再次编译运行程序看看效果吧，当你再次编译程序时，却会发现编译失败了，编译器发出类似
```c++
FindDialog.o：在函数‘FindDialog::FindDialog(QWidget*)’中：
FindDialog.cxx:(.text+0x19)：对‘vtable for FindDialog’未定义的引用
FindDialog.cxx:(.text+0x20)：对‘FindDialog::staticMetaObject’未定义的引用
collect2: error: ld returned 1 exit status
```
这样的警告信息，这个是GCC编译器，如果使用VS编译器，出现的警告信息也会差不多。为什么刚刚好好的，添加了一个FindDialog对象程序就编程这样了呢？原因在于类定义的第一行添加一个宏Q_OBJECT,需要重新构建项目，既重新生成.pro文件（方法参考第2章），然后重新编译。

另一个相对简单的方法就是用编译器打开.pro文件，随意添加或删除一个空行，然后再次编译，这个方法在使用QtCreator时非常简单。

## 留下的问题

1. 这个对话框还有很多功能没有做上去，当然，这个需要和记事本程序一起完成，所以其他的功能留到后面和记事本完成

2. 可能你已经发现这个程序不再想以前那样，“一点点内存泄漏关系不大”，内存是否泄漏很重要，前面的章节之所以演示一些错误的做法是希望你不要犯类似的问题，具体的情况很快就会讲述

3. 如果你熟悉windows的记事本程序，你会发现，他的对话框和这个有些不同，差不多应该是这个样子

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/QtNotes/5-2.png)

这里查询方向使用了QGroupBox和QRadioBox的组合，关于这两个窗体部件使用可以参加Qt Assistant，然后写一个这样的程序

4. 使用Qt Assistan,这很重要，非常的重要，Qt的内容太多，不可能记住所有，任何教材也只能介绍很少一部分内容，当遇到问题时，如QGroupBox和QRadioBox的使用，Qt Assistant上可以找到答案


