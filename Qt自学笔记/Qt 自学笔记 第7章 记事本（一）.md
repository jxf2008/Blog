## QMainWindow
接下来的几章将介绍如何制作在上一章提到的window记事本程序，这个程序本身并不复杂，但因为为需要穿插介绍一些其他内容，所以这个过程会显得比较长。在这一章里将先演示窗体的制作。

我们先把程序的界面做好，完成后的程序应该是这个样子的

这里简单介绍下Qt的最基本的3个窗体，QWidget,QDialog和QMainWindow。

1.**QWidget**是Qt实现窗体的基础类，窗体（包括QDialog和QMainWindow)都继承自该类（有没有注意到前面几章例子里，有关窗体的类的构造函数里，都有默认参数QWidget* parent = 0，说明所有窗体的类都可以通过类型转化为QWidget），该类提供了大量有关窗体的基本函数，实际应用时，该类直接使用的不多。

2.**QDialog**提供了对话框的基本功能，在计算机界面程序中，各种弹出对话框非常常见，因此Qt提供了该类用于对话框的基本功能。实际应用中，都会自定义一个类继承自QDialog，然后在对话框上放上各种控件/窗体来实现某些功能，前一章的查询对话框就是一个例子

3.**QMainWindow**是本章已经后续几章的主角，该类最大的特点就是提供了菜单栏，状态栏，滚动条等一系列非常常见的功能，以菜单为例，如果开发者需要实现一个菜单栏是一件非常复杂的事情，而QMainWindow最大的作用就是已经做好了大部分的工作。他还有一个非常重要作用就是可以将另一个窗体部件指定为他自身的中心窗体

在这个程序里，使用了QTextEdit来做为中心窗体，和上一章使用的面向行的文本编辑窗体QLineEdit相比，QTextEdit的功能更加适合大段的文本编辑。

## ReadTxt界面

这个程序通过继承QMainWindow类来实现，我把他称为ReadTxt,先来看他的头文件ReadTxt.h

```c++
#include <QMainWindow>
#include <QTextEdit>
#include <QAction>
#include <QMenuBar>
#include <QMenu>

class ReadTxt:public QMainWindow
{
private:
    QAction* open_Action;   //注释1
    QAction* new_Action;
    QAction* save_Action;
    QAction* saveAs_Action;
    QAction* close_Action;
    QAction* redo_Action;
    QAction* undo_Action;
    QAction* cut_Action;
    QAction* copy_Action;
    QAction* paste_Action;
    QAction* delete_Action;
    QAction* find_Action;
    QAction* findNext_Action;
    QAction* selectAll_Action;
    QAction* dataAndTime_Action;
    QAction* autoChangeLine_Action;
    QAction* leftAlignment_Action;
    QAction* rightAlignment_Action;
    QAction* midAlignment_Action;
    QAction* font_Action;
    QAction* findHelp_Action;
    QAction* about_Action;
   
    QMenuBar* fileMenu_MenuBar;   //注释2
    QMenu* file_Menu;
    QMenu* edit_Menu;
    QMenu* format_Menu;
    QMenu* help_Menu;
 
    QTextEdit* editor_TextEdit;
public:
    ReadTxt(QWidget* parent = 0);
private:
    void createAction();   //注释3
    void createMenu();
    void createMenuBar();
    void connectSignalAndSlot();
};
```

题外话：我当初学Qt时，因为看的是<C++ Qt4 GUI编程>，这个时间节点上我唯一的记忆是一个无比冗长的，包含大量没见过的内容的头文件，我已经忘记当时如何跨过这道坎的，唯一还记得的是当初内心的无助和惶恐，我当时差点就因为这个放弃Qt了。但后来回过头来再看这个例子时，我真心觉得没必要选择一个如此复杂还要穿插后面章节内容的例子，我想遇到我这种情况的人绝对不止一个，所以我想着，一定要找个能够充分说明问题且足够简单的例子来代替<C++ Qt4 GUI编程>那个制表程序。这也是促使我写<Qt自学笔记>的重要原因

>注释1 ：这里使用了大量的QAction（即动作），这些QAction的作用和他们的名字一样，打开，保存，另存为，剪切，复制，等等，而这些动作最后都会被安装到菜单上,一个菜单会包含多个菜单项，而这里每个菜单项其实就是一个QAction.

>注释2 ：这里有需要区别下菜单QMenu和菜单栏QMenuBar，其中QMenu在添加了各种动作（比如剪切，复制等等）后成为一个正真的菜单（否则只是一个没用任何内容的空菜单），然后这些菜单按照你需要的顺序添加到菜单栏上，这样就完成了菜单栏,以ReadTxt为例,下图可以说明菜单和菜单栏的区别

>注释3 ：这里使用了4个私有函数来分别创建动作，菜单，菜单栏以及连接信号与槽，其实这些代码都可以直接写在构造函数里，不过由于完成后的例子代码较长，同时也为了方便修改，所以创建私有函数完成，然后在构造函数中将会调用这些函数。当然，如果你不嫌弃构造函数太长的话，也可以不用这些私有函数。

接下来就是实现这个头文件里的内容，首先看CreateAction（）函数
```c++
void ReadTxt::createAction()
{
    open_Action = new QAction("打开",this);   //注释4
    new_Action = new QAction("新建",this);
    save_Action = new QAction("保存",this);
    saveAs_Action = new QAction("另存为...",this);
    close_Action = new QAction("关闭",this);
 
    redo_Action = new QAction("撤销",this);
    undo_Action = new QAction("恢复",this);
    cut_Action = new QAction("剪切",this);
    copy_Action = new QAction("复制",this);
    paste_Action = new QAction("粘帖",this);
    delete_Action = new QAction("删除",this);
    find_Action = new QAction("查询",this);
    findNext_Action = new QAction("查询下一个",this);
    selectAll_Action = new QAction("全选",this);
    dataAndTime_Action = new QAction("日期/时间",this);
 
    autoChangeLine_Action = new QAction("自动换行",this);
    leftAlignment_Action = new QAction("左对齐",this);
    rightAlignment_Action = new QAction("右对齐",this);
    midAlignment_Action = new QAction("中对齐",this);
    font_Action = new QAction("字体",this);
 
    findHelp_Action = new QAction("关于帮助",this);
    about_Action = new QAction("关于记事本",this);
}
```

>注释4：该函数代码比较长，但内容比较单一，这里创建了大量的动作QAction,他们对应的功能和他们的名字一样。这里要注意下QAction这个类，这个类和前面介绍的Qt的类有所不同，QAction虽然也继承自Qwidget，但马上就会看到，QAction被安装到菜单上的时候并不是通过布局管理器，前面说过，窗体控件可以通过布局管理器安装到父窗体上，因而在创建时不用显示的声明父对象。但QAction没有放入布局管理器中，所以必须在构造时显式的指定父对象。

然后是CreateMenu()函数
```c++
void ReadTxt::createMenu()
{
    file_Menu = new QMenu("文件");  
    file_Menu->addAction(open_Action);
    file_Menu->addAction(new_Action);
    file_Menu->addAction(save_Action);
    file_Menu->addAction(saveAs_Action);
    file_Menu->addSeparator();            //注释5
    file_Menu->addAction(close_Action);
 
    edit_Menu = new QMenu("编辑");
    edit_Menu->addAction(redo_Action);
    edit_Menu->addAction(undo_Action);
    edit_Menu->addSeparator();
    edit_Menu->addAction(cut_Action);
    edit_Menu->addAction(copy_Action);
    edit_Menu->addAction(paste_Action);
    edit_Menu->addAction(delete_Action);
    edit_Menu->addSeparator();
    edit_Menu->addAction(find_Action);
    edit_Menu->addAction(findNext_Action);
    edit_Menu->addSeparator();               
    edit_Menu->addAction(selectAll_Action);
    edit_Menu->addAction(dataAndTime_Action);
 
    format_Menu = new QMenu("格式");
    format_Menu->addAction(autoChangeLine_Action);
    format_Menu->addSeparator();
    format_Menu->addAction(leftAlignment_Action);
    format_Menu->addAction(rightAlignment_Action);
    format_Menu->addAction(midAlignment_Action);
    format_Menu->addSeparator();
    format_Menu->addAction(font_Action);
 
    Help_Menu = new QMenu("帮助");
    Help_Menu->addAction(findHelp_Action);
    Help_Menu->addAction(about_Action);
}
```
>注释5：同样代码很多，这里分别创建了文件，编辑，合适，帮助这四张菜单，然后将动作QAction添加值对应的菜单，这里可以看到，菜单安装QAction时并没有通过布局管理器。唯一需要注意的是类QMenu的成员函数addSeparator(),这个函数的作用是在菜单中画出一条横向分割线

接下来轮到CreateMenuBar()函数
```c++
void ReadTxt::createMenuBar()
{
    fileMenu_MenuBar = menuBar();  //注释6
    fileMenu_MenuBar->addMenu(file_Menu);
    fileMenu_MenuBar->addMenu(edit_Menu);
    fileMenu_MenuBar->addMenu(format_Menu);
    fileMenu_MenuBar->addMenu(help_Menu);
}
```

>注释6：这章开始的时候说过，QMainWindow提供了菜单栏，需要的话调用对于的成员函数即可，这里就调用了成员函数menuBar(),这个函数的作用就是创立一个QMenuBar，并且返回一个指向(该函数创建的)QMenuBar的指针,然后就可以把菜单按照顺序安装到菜单栏上

最后是构造函数
```c++
ReadTxt::ReadTxt(QWidget* parent):QMainWindow(parent)
{
    createAction();  //注释7
    createMenu();
    createMenuBar();
    editor_TextEdit = new QTextEdit;  //注释8
    setCentralWidget(editor_TextEdit);
    setWindowTitle("记事本");
    void connectSignalAndSlot();    //注释9
}
```
>注释7： 首先在构造函数中调用3个私有函数创建动作，菜单和菜单栏，这里注意他们调用的顺序

>注释8：创建一个QTextEdit作为编辑文本的窗体，然后将这个窗体设为中心窗体（即调用setCentralWidget())

>注释9：注意这个用于链接信号和槽的函数的调用顺序，必需等所有对象都创建后才能进行连接，连接到一个未创建的对象的话，在程序运行是会出现段错误,

到这里程序可以编译运行了，大家可以编译运行下，看下样子，记事本的基本样子都是有了，当然这个时候程序还只是一个空壳子，没有任何功能，接下来要一步一步的实现他的功能。

## 添加查询对话框

在第5章，我们制作了一个查询对话量，既FindDialog,现在我们需要把这个查询对话框加入到ReadTxt里面.首先，我们需要在ReadTxt的类定义里添加一个类成员
```c++
FindDialog* find_Dialog;
```
然后在ReadTxt的构造函数里对他初始化
```c++
find_Dialog = null;   //注释10
```
>注释10：????是不是吃了一惊，为啥这里直接给他复制为null啊？没关系，稍后解释为什么这么做。

在添加完FindDialog后，我们希望的功能时，每次点击菜单“查询”的时候，都会显示这个对话框，而Qt的窗体创建时默认是隐藏的，所以第一步想到的就是通过信号与槽的连接，每次用户点击时，就创建一个FindDialog并显示，用户关闭时就删除FindDialog，但这里遇到一个问题，当用户再次点击“查询”时，如果FindDialog处于最小化状态呢？

为了解决这个问题，在每次创建FindDialog前需要做一定的判断，为此，我们需要在ReadTxt的构造函数里添加一个私有槽
```c++
private slots:
    void showFindDialog();
```

这个槽最终在私有函数void connectSignalAndSlot()里和对应的信号连接
```c++
void ReadTxt::connectSignalAndSlot()
{
    connect(find_Action,SIGNAL(triggered()),this,SLOT(showFindDialog()));  //注释11
}
```
>注释11 这里将动作"查询"和showFindDialog()连接起来，QAction被点击后会发出triggered()信号

最后来看下槽函数showFindDialog()的实现
```c++
void ReadTxt::showFindDialog()
{
    if(find_Dialog != null)
        find_Dialog = new FindDialog(this);   //注释12
    find_Dialog->show();
    find_Dialog->Raise();
    find_Dialog->activateWindow();    //注释13
}
```
>注释12：每次用户点击“查询”时，程序就会调用这个showFindDialog()函数，首先要查询下，这个对话框有没有创建，在ReadTxt构造函数里，find_Dialog被赋值为null。这里检查发现find_Dialog的值为null,所以需要构造一个FindDialog对象。这里另一个需要注意的地方就是构造FindDialog时显示的申明了父窗体为this,前面说过，Qt的窗体/控件通过布局管理器放入别的窗体时，就没必要显示申明父窗体了，但这里的find_Dialog没有放入布局管理器中，因此，我们需要在构造时显示的申明他的父窗体.

>注释13：这里一口气调用了3个函数，他们的作用分别是和函数名一样。首先，对话框需要显示出来，然后，用户点击“查询”的时候，查询对话框在上次的调用中并没有关闭，而是位于别的窗体下面，Raise()函数把查询对话框“上升”到其他窗口的上面。最后。调用activateWindow()函数是的查询对话框处于激活状态。

这里额外穿插一个关于对话框**模态调用**的概念。其实对话框的显示有两种方式，模态（show()）和非模态（exec()）,以window自带的记事本程序为例，他弹出的查询对话框是**非模态调用**，对话框弹出后，你可以在不关闭对话框的情况下操作程序的其他窗体；而记事本弹出的“保存文件”就是典型的**模态调用**，这种类型对话框弹出后，除非用户关闭该对话框，否则无法在操作程序的其他对话框,如果对话框是模态调用的，也就没必要使用Raise()和activateWindow()这两个函数了，因为模态对话框始终位于最上面并且始终处于激活状态。

到这里算是完成了ReadTxt程序的第一项功能，再次编译运行程序看看效果吧，点击QtCreator的编译时，这个时候却会发现编译失败了，编译器发出类似
```c++
FindDialog.o：在函数‘FindDialog::FindDialog(QWidget*)’中：
FindDialog.cxx:(.text+0x19)：对‘vtable for FindDialog’未定义的引用
FindDialog.cxx:(.text+0x20)：对‘FindDialog::staticMetaObject’未定义的引用
collect2: error: ld returned 1 exit status
```
这样的警告信息，这个是GCC编译器，如果使用VS编译器，出现的警告信息也会差不多。为什么刚刚好好的，添加了一个FindDialog对象程序就编程这样了呢？原因在于除了添加FindDialog外，ReadTxt程序里还添加了一个私有槽，而在前一章里就介绍过了，Qt窗体如果需要添加自定义的信号与槽，必须在类定义的第一行添加一个宏Q_OBJECT,而ReadTxt添加了自定义槽，却没有添加宏，所以才造成了这个现象

解决这个问题也很简单，只要在ReadTxt类定义的第一行添加Q_ONJECT宏，然后**重新构建**并编译，如果你觉得手动点击构建麻烦，最简单的办法就是在项目的.pro文件里添加或删减一个空行，然后直接点击编译就行，QtCreator在编译前会检测到.pro文件，如果发现.pro文件发生了变化，就会自动重新构建。