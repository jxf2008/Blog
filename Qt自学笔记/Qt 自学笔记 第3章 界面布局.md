## 布局管理器

Qt的界面布局相对比较简单，虽然从代码角度来说可能有些长，但其实要理解他并不困难。

Qt的界面主要依赖2个布局管理器，分别是<font color=pink>QHBoxLayout</font>和<font color=pink>QVBoxLayout</font>这两个类，用于水平方向和垂直方向上的界面布局，通过这两个界面<font color=pink>布局管理器</font>和<font color=pink>弹簧</font>，我们可以应付绝大多数的场景，当然Qt还有很多用于界面布局的类，这些类主要用于一些特殊或者精确布局上，我会在以后用到的时候再分析

第一章使用了一个QLabel来作为演示，当然也可以用QPushButton来，而这里我们则使用8个QPushButton放在一个对话框里。

```c++
#include <QApplication>
#include <QDialog>
#include <QHBoxLayout>
#include <QVBoxLayout>
#include <QPushButton>

int main(int argc , char** argv)
{
    QApplication app(argc,argv);
 
    QDialog* dg_Dialog = new QDialog;  //注释1
    QPushButton* a_PushButton = new QPushButton("按钮a");
    QPushButton* b_PushButton = new QPushButton("按钮b");
    QPushButton* c_PushButton = new QPushButton("按钮c");
    QPushButton* d_PushButton = new QPushButton("按钮d");
    QPushButton* e_PushButton = new QPushButton("按钮e");
    QPushButton* f_PushButton = new QPushButton("按钮f");
    QPushButton* g_PushButton = new QPushButton("按钮g");
    QPushButton* h_PushButton = new QPushButton("按钮h");
  
    QHBoxLayout* hFirst_Layout = new QHBoxLayout;   //注释2
    QHBoxLayout* hSecond_Layout = new QHBoxLayout;
    QHBoxLayout* hThrid_Layout = new QHBoxLayout;
    QVBoxLayout*top_Layout= new QVBoxLayout;
 
    hFirst_Layout->addWidget(a_PushButton);  //注释3
    hFirst_Layout->addWidget(b_PushButton);
    hFirst_Layout->addWidget(c_PushButton);
    hSecond_Layout->addWidget(d_PushButton);
    hSecond_Layout->addWidget(e_PushButton);
    hSecond_Layout->addWidget(f_PushButton);
    //hThrid_Layout->addStretch();  //注释4-1
    hThrid_Layout->addWidget(g_PushButton);
    hThrid_Layout->addWidget(h_PushButton);
    //hThrid_Layout->addStretch();  //注释4-2
 
    top_Layout->addLayout(hFirst_Layout); //注释5
    top_Layout->addLayout(hSecond_Layout);
    top_Layout->addLayout(hThrid_Layout);
 
    dg_Dialog->setLayout(top_Layout); //注释6
    dg_Dialog->show();
 
    return app.exec();
}
```
初看代码挺长的，正如上面所说，界面布局的代码通常时非常有规律的

首先这里出现了一个类QDialog,顾名思义他是一个对话框，在界面程序中，对话框是非常常见的一个窗体，在Qt中，对话框（QDialog）大多数时候用于在上面摆放各种其他窗体，今天的例子我们就是在对话框上摆上8个按钮来说明布局的问题。

这段代码编译后运行，应该是这个样子

![](https://github.com/jxf2008/blog/raw/master/pix/QtNotes/3-1.png)

然后我们来详细看下代码中注释的地方

+ 注释1 这里生产了一个对话框（QDialog）做为父窗体，8个按钮作为子窗体，关于父/子窗体的概念在本章最后说明。这里就先理解为生产了一个对话框和八个按钮

+ 注释2 生成了4个布局管理器，3个垂直（QVBoxLayout）和1个水平(QHBoxLayout)

+ 注释3 使用了布局管理器的两个重要的成员函数addWidget()和addLayout(),他们的作用正如函数名那样，addWidget()用于按顺序添加窗体，而addLayout()则用于布局管理器的嵌套，这里第一个和第二个水平方向的布局管理器个放了三个按钮，第三个水平方向的布局管理器则放了两个

+ 注释4-1，4-2，这两行代码也位于注释中，我们先跳过这两行被注释掉的代码

+ 注释5  把三个水平方向布局管理器按顺序放入一个垂直方向的布局管理器，使用了addLayout()函数

+ 注释6 这是对话框的一个成员函数setLayout()，作用就是把完成的布局管理器安装在本窗体上，这里布局管理器top_layout(作为函数的参数）被安装在了对话框上

## 布局调整

对于很多窗体来说，视觉效果是个很重要的组成部分，对于上面一个窗体来说，上面布局似乎有点太不协调了，也许有人希望界面是这个样子的。

![](https://github.com/jxf2008/blog/raw/master/pix/QtNotes/3-2.png)

这里就提出了一个要求，如何让按钮g和按钮h位于最左侧呢？这里就用到弹簧了，按钮g和h都是按顺序放入了一个水平方向的布局管理器中，这时候我们在这个布局管理器中再添加一个弹簧就能达到这个效果了，这就是注释4-2中函数addStretch()的作用，现在我们把注释4-2的代码注释取消掉再编译，就可以得到这样的效果了(先别把注释4-1取消)

然后我们把窗体拉伸一下

![](https://github.com/jxf2008/blog/raw/master/pix/QtNotes/3-3.png)

这样弹簧的效果可以更明显的显示出来。

这时候，也许有人会提出，我希望这两个按钮始终位于中间呢？那也很简单，只需要在按钮之前再添加一个弹簧就可以了，把上面代码里注释4-1的代码注释取消掉就能实现这样的效果

同时我们也可以看到，弹簧在窗体拉伸的时候保持按钮的形状和大小也有很大的作用，当然一个按钮（或其他窗体）的大小设置是个很复杂的问题，具体会在以后的单独章节里详细讲解。不过，大多数时候，两个<font color=pink>布局管理器</font>再加上<font color=pink>弹簧</font>可以应付大多数情况了

 关于上面的按钮拜访，也可以作出下面这个样子

 ![](https://github.com/jxf2008/blog/raw/master/pix/QtNotes/3-2.png)

看起来似乎是和上面的例子是一样的，但我们拉伸一下就看出区别了

![](https://github.com/jxf2008/blog/raw/master/pix/QtNotes/3-4.png)

第一个例子，我们使用的是3个垂直的布局管理器（QVBoxLayout),然后用一个水平的布局管理器（QHBoxLayout）作为<font color=pink>父布局管理器</font>，而这个例子，则使用了3个水平布局管理器，然后用一个垂直布局管理器作为<font color=pink>父布局管理器</font>。其实本质就是更换了布局管理器嵌套的方式，有兴趣的可以自己实现下。

## 父窗体/子窗体

上面细心的同学，可能发现了一个新的术语<font color=pink>父布局管理器</font>,其实这术语是我自己起的。。。。好吧，其实这里需要说明一个Qt中非常重要的概念<font color=pink>父窗体</font>和<font color=pink>子窗体</font>。

本章的例子和第一章的Hello Qt一样有着内存泄漏的问题，正如我前面所说，在即将到来的内存管理篇章之前，先暂时忽略内存泄漏的问题，<font color=pink>父窗体</font>和<font color=pink>子窗体</font>是一个Qt中很重要的概念，任何窗体都可以成为子窗体和父窗体，在Qt编程中，顶层窗体是父窗体，他是一个没有父窗体的父窗体，而其他的父窗体均有自己的父窗体，换句话说，除顶层窗体外，所有的父窗体都会是别的窗体的子窗体。

一般来说，创建一个窗体后必须声明他的父窗体，如果没有就认为该窗体为顶层窗体，但有个例外，当窗体A被放入布局管理器中后，通过布局管理器安装在窗体B上，Qt就会默认窗体A是窗体B的子窗体，这样就不必先显示的声明。Qt窗体的构造函数都有一个指针参数（默认参数，默认值为0），用于在创建的时候显示的声明他的父窗体，比如上文的按钮，如需要显示声明他是对话框的子窗体，则应该有

```c++
QPushButton* a_pushbutton = new QPushButton("按钮a",dg_dialog);
```

但是由于a_PushButton最后通过布局管理器放入了dg_Dialog中，所以在构造a_PushButton对象时，就不用显示的声明他的父窗体了。

 这样一个概念被用于描述窗体的布局，比如上面的例子，8个按钮是对话框的子窗体，而对话框则是按钮的父窗体，当然作为顶层窗体的对话框，在这个程序里没有父窗体。

其实<font color=pink>父窗体</font>和<font color=pink>子窗体</font>的概念在布局管理中只是他们的“副业”，他们最终要的最用就是在后面的内存管理中，对于Qt的内存管理中，父窗体和子窗体的概念用于描述内存直接的关系，具体将在内存一节中详解。
