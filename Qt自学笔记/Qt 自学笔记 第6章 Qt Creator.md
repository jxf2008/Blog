## 简介

Qt Creator是一款用于开发Qt程序的IDE，最初的功能是方便用户开发Qt的，随着版本的发展，QtCreator功能越来越多，比如我经常用它来写Python，以及一些非Qt的C++项目。

## 创建新工程

在前面的章节的例子，都是使用编辑器编写代码，然后通过命令行编译，而在后面的章节将会使用QtCreator来开发，以前一章的FindDialog类为例，创建了一个继承自Qdialog的类，需要一个.h文件和一个.cpp文件用于实现类的声明和定义，然后又添加了一个Main.cpp文件用于主函数，而这些步骤可以通过QtCreator自动完成。下面我们看下，以前一章FindDialog为例，QtCreator如何完成这项工作的

1.QtCreator打开后大概是这个样子，“New Project"用于新建一个新的工程，而"Open Project”则记录着曾经打开过的项目
![](https://github.com/jxf2008/blog/raw/master/pix/QtNotes/6-1.png)

2.这里点击“New Project”或者点击“文件->新建文件或项目(N)...”打开项目选项，项目选择"Application"的“Qt Widgets Application”,从项目列表上可以看出Qt Creator还可以用于开发其他类型的项目。
![](https://github.com/jxf2008/blog/raw/master/pix/QtNotes/6-2.png)

3.点击确定后，弹出项目位置对话框，这个对话框要求设定项目的名称（默认名称为untitled）和项目的位置。这里我们把项目名称设为FindDialog，项目位置选择一个合适的目录
![](https://github.com/jxf2008/blog/raw/master/pix/QtNotes/6-3.png)

4.点击确定后，进入选择套件对话框，如果你没有在QtCreator设置里额外添加套件，那这一步可以忽略，直接点击确定即可。一般这步适用于那些电脑里装了多个版本的Qt，在创建项目时需要选择使用哪个版本，哪个编译器
![](https://github.com/jxf2008/blog/raw/master/pix/QtNotes/6-4.png)

5.接下来是项目信息对话框，首先类名直接填写FindDialog,基类有3个选择，因为FindDialog继承自QDialog,所以这里就选择QDialog。关于基类的3个选择，下一章会详述。当你修改类名时，头文件和源文件的名称会自动更改，一般不必再次修改。需要注意的是下面有个创建界面的单选框，一定要取消掉。在确认无误后，点击下一步，一个项目就创建好了
![](https://github.com/jxf2008/blog/raw/master/pix/QtNotes/6-5.png)

>关于创建界面

Qt的界面布局有两种方式，一种是前面介绍的，使用布局管理器，手动编写代码，另一种方法就是可视化编辑，这两种不能同时使用，所以才一定要把“创建界面”的单选框取消掉，如果不取消，编译就无法通过，IDE会发出“已经存在一个布局管理器”的警告信息。整个<Qt自学笔记>中将只会使用编写代码的方式来布局，我会专门用一个章节介绍下Qt可视化布局的方法，以及为什么我不用可视化编程的原因——使用可视化编辑布局虽然更方便更直观，但有些时候会是一场灾难。

## 添加类

1.在新建一个新的项目后，还需要添加额外的类，由于Qt Creator可以同时打开多个工程，所以需要选择一个工程，然后右键该工程，选择“Add New...”
![](https://github.com/jxf2008/blog/raw/master/pix/QtNotes/6-6.png)

2.在"新建文件”对话框中，选择需要添加的文件类型，如果你要添加一个类，可以选择"c++"->"c++class",如果你要选择添加一个Qt的资源文件，则可以选择"Qt"->"资源文件",等等。关于资源文件会在第8章详细讲述
![](https://github.com/jxf2008/blog/raw/master/pix/QtNotes/6-7.png)

3.如果你选择了添加类，那会跳转至“c++ class”对话框，这里可以输入你的类名，以及基类的名称，选择不同的基类，Qt Creator会为你自动生成一些相关的代码，当然这些影响不大，你可以生成以后在根据实际需求在做修改
![](https://github.com/jxf2008/blog/raw/master/pix/QtNotes/6-8.png)

## 可视化布局

这一章简单的介绍下Qt的可视化布局，然后说明下为什么我不用这个东西。当然，我这里说的是我不用可视化的原因，并不代表你也不可以用，这个类似命名的风格，完全是个人的喜好，我一直以为在这种事情的争论是徒劳且永远不会有结果的。。。。

首先我们通过Qt Creator新建一个GuiLayout项目，然后在新建项目对话框中不要取消“界面文件”的选项，点击确定后，发现新建的项目里多了个“Forms”的目录，里面有个“GuiLayout.ui”的文件，文件名一般为项目名，同时类的代码也出现了变化，在头文件中多了一个
```c++
namespace Ui {
class GuiLayout;
}
```
而这个自动生成的类成为了GuiLayout类的成员，当然GuiLayout的类定义文件也出现相应的变化

双击"GuiLayout.ui"文件，就会进入Qt Creator的可视化编辑模式，其中有3个比较重要的区域
![](https://github.com/jxf2008/blog/raw/master/pix/QtNotes/6-9.png)

1. <font color=yellow>控件区</font>，这里包含了Qt的控件

2. <font color=red>编辑区</font>，这里其实就是对话框GuiLayout的界面，上面什么都没有，可以将需要的控件从控件区拖放至编辑区，然后通过鼠标的拖动来改变控件的位置和大小

3. <font color=green>控件属性区</font>，选择编辑区的一个控件，然后在这个区域设置控件的属性，基本上控件的各个属性都可以在这里设置，而不用在GuiLayout类中实现

注意，这里的控件区，编辑区和控件属性区是我起的名字，我并不知道他们的官方名字叫什么。。。

最后一个问题是为什么我不用可视化布局，这里先介绍一个类**QGridLayout**，这个类看名字就知道他和前面介绍的**QHBoxLayout**和**QVBoxLayout**一样，属于布局管理器，该布局管理器最大的用处是进行类似二维网格的布局，在添加控件的时候需要指定控件在网格的相对位置,假设有对话框上需要防止4个按钮，一个办法就是使用前面介绍的布局管理器的嵌套，另外一个就是使用QGridLayout,
```c++
grid_Layout->addWidget(A,0,0);
grid_Layout->addWidget(B,0,1);
grid_Layout->addWidget(C,1,0);
grid_Layout->addWidget(D,1,1);
```
GridLayout在添加控件时需要指定控件在“网格”中的位置，他添加控件的函数为
```c++
grid_Layout->addWidget(widget,row,column,rSpan,cSpan);
```
其中rSpan,cSpan表示控件在网格中占据的大小，默认每个控件占据1行和1列，这个**QGridLayout**在大量重复控件的布局中非常有用，比如我写过一个[扫雷](https://github.com/jxf2008/MineLand)，类似这个样子

![](https://github.com/jxf2008/MineLand/raw/master/扫雷.png)

在一个界面上放置了15X15个按钮，通过**QGridLayout**实现非常简单
```c++
QGridLayout* main_Layout = new QGridLayout;
for(int rows = 0 ; rows < MINE_COUNT ; ++rows)
{
    for(int columns = 0 ; columns < MINE_COUNT ; ++ columns)
    {
        mine_List.append(new MineButton(rows,columns));   //注释1
        main_Layout->addWidget(mine_List.last(),rows,columns);

    }
}
```
+ 注释1 这里的mine_List用于存放自定义控件的MineButton的指针

然后你可以尝试下使用可视化的方式来完成这个布局