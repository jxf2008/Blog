## 资源文件

在有图像界面的程序中，添加一些图片是很常见的事，这些图片可以作为log，背景等，而在这里演示的是将一些图片添加到菜单中,并作为工具栏的内容。
Qt中使用一种qrc格式的文件来作为添加资源的文件，注意这里是添加的资源不限于图片，其他音频视频也可以这样添加。

1.在程序目录下新建一个images的子文件目录，然后将需要的图片放入这个子目录。如果有别的类型的资源比如视频，可以新建另一个子目录videos，当然，你如果你喜欢，把这些资源文件放在一个目录里也完全没问题，至于目录的名称可以是任意你喜欢的名称，但需要注意的是不要使用中文目录，Qt有些时候加载资源文件时，如果目录或者文件名带有中文会出错。

2.建立一个.qrc文件，例子中是pix.qrc，文件名并没有限制，只要符合系统要求（貌似这是废话，文件名如果非法的话，系统也不让创建。。）具体内容为XML格式 。然后在QtCreator中选择“添加已经存在的文件”，把该文件添加入项目即可。或者可以在QtCreator上右键项目，选择“Add New”,然后选择“Qt”的“Qt Source File”,如下图

点击“确定”后，填入文件名就可以了，比如这个例子我的文件名填写的是pix。然后工程下多了一个Resources的目录，目录下有个文件pix.qrc

右键pix.qrc文件，依次选择"Open With"->"普通文本编辑器",打开后是个空的文件，较新的Qt版本里，文件可能会存在
```xml
<!DOCTYPE RCC>
<RCC version="1.0"/>
```
这两行没什么用，可以直接删除，当然你愿意留着也不会有任何问题。接下来就是往资源文件里添加资源，.qrc文件使用xml格式来添加资源。
```xml
<RCC>
    <qresource>
        <file>images/center.png</file>
        <file>images/copy.png</file>
        <file>images/cut.png</file>
        <file>images/delete.png</file>
        <file>images/files.ico</file>
        <file>images/left.png</file>
        <file>images/new.png</file>
        <file>images/open.png</file>
        <file>images/paste.png</file>
        <file>images/read.png</file>
        <file>images/re.png</file>
        <file>images/right.png</file>
        <file>images/saveAs.png</file>
        <file>images/save.png</file>
        <file>images/un.png</file>
    </qresource>
</RCC>
```
前面提到，我在工程的目录下新建了一个images的目录，然后把图片都放在了./images下，所以不用使用绝对路径，如果你想加载非工程目录下的图片也可以，但必须使用绝对路径，比如
```xml
<file>/home/jxf2008/pix/blogPix/center.png</file><!--Linux-->
<file>E:/pix/blogPix/center.png</file><!--Windows-->
```
当然，一般不建议这么做。

## 添加图片

当图片通过资源文件添加进工程后，就可以早工程中通过代码来使用他们了。在ReadTxt的例子中，可以给菜单上一些菜单项（QAction）添加图片来提升程序的用户体验。为实现这项功能，需要通过在ReadTxt类中添加一个私有函数setActionPix()来完成。具体代码如下
```c++
void ReadTxt::setActionPix()
{
    new_Action->setIcon(QIcon(":/images/new.png"));   //注释1
    open_Action->setIcon(QIcon(":/images/open.png"));
    save_Action->setIcon(QIcon(":/images/save.png"));
    saveAs_Action->setIcon(QIcon(":/images/saveAs.png"));
 
    redo_Action->setIcon(QIcon(":/images/re.png"));
    undo_Action->setIcon(QIcon(":/images/un.png"));
    cut_Action->setIcon(QIcon(":/images/cut.png"));
    copy_Action->setIcon(QIcon(":/images/copy.png"));
    paste_Action->setIcon(QIcon(":/images/paste.png"));
    delete_Action->setIcon(QIcon(":/images/delete.png"));
 
    leftAlignment_Action->setIcon(QIcon(":/images/left.png"));
    rightAlignment_Action->setIcon(QIcon(":/images/right.png"));
    midAlignment_Action->setIcon(QIcon(":/images/center.png"));
}  
```
>注释1：这里出现了一个新的类QIcon,这是Qt用于处理图像的众多类中的一个。和之前介绍的类有所不同，QIcon并非继承自QWidget,也就是说他不是一个窗体类，关于他的详细使用会在后面的图片处理章节在做介绍，这里只需要了解该类的构造函数接收一个图片路径为参数。这里另一个需要注意的点是图片路径，以"new.png"为例，他在资源文件中路径是“images/new.png”,而代码中调用他时路径为“:/images/new.png”。


## 工具栏

到这里完成了给菜单上的动作添加图片的工作，接下来的任务是给这个程序添加一个工具栏，在QMainWindow中，成员函addToolBar()用于添加一个工具栏，同时返回指向(该函数创建的)工具栏的指针，这个指针的类型是QToolBar*，在文件中添加包含这个类的头文件,同时在添加一个用于创建工具栏的私有函数createToolBar()来具体实现。

ReadMe.h文件应该添加下面的代码
```c++
#include<QToolBar>
//..
//.
private:
    QToolBar* fileTools_ToolBar;
    QToolBar* editTools_ToolBar;
    QToolBar* formatTools_ToolBar;
//..
    void createToolBar();
```
然后在ReadTxt.cxx文件中实现这个函数的功能
```c++
void ReadTxt::createToolBar()
{
    fileTools_ToolBar = addToolBar("文件");  //注释2
    fileTools_ToolBar->addAction(new_Action);
    fileTools_ToolBar->addAction(open_Action);
    fileTools_ToolBar->addAction(save_Action);
    fileTools_ToolBar->addAction(saveAs_Action);
 
    editTools_ToolBar = addToolBar("编辑");
    editTools_ToolBar->addAction(redo_Action);
    editTools_ToolBar->addAction(undo_Action);
    editTools_ToolBar->addAction(cut_Action);
    editTools_ToolBar->addAction(copy_Action);
    editTools_ToolBar->addAction(paste_Action);
    editTools_ToolBar->addAction(delete_Action);
 
    formatTools_ToolBar = addToolBar("格式");
    formatTools_ToolBar->addAction(leftAlignment_Action);
    formatTools_ToolBar->addAction(midAlignment_Action);
    formatTools_ToolBar->addAction(rightAlignment_Action);
}
```
>注释2： QMainWindow类的成员函数addToolBar()创建一个工具栏，在默认情况下，QMainWindow的工具栏是不创建的，如果需要创建，调用下该函数即可，同时该函数返回指向这个工具栏的指针，然后就可以向这个工具栏里添加动作(QAction),创建工具栏和创建菜单栏很相似，又有些区别，可以仔细对比下createMenu(),createMenuBar()和createToolBar()的区别。

## 状态栏

接下来是个程序添加一个状态栏，一般状态栏位于程序的底部，用于说明某些功能的详细，QMainWindow类成员函数statusBar()会在第一次调用时创建一个状态栏，我们这里要做的是当鼠标悬停在菜单上的某个选项（即QAction)时，状态栏会给出这个选项的详细说明,而QAction类提供了一个成员函数setStatusTip()来实现这个功能，现在将这个功能整合到我们的程序ReadMe中

首先在ReadTxt.h文件中添加一个私有函数void createStatusBar();
具体实现如下
```c++
void ReadTxt::createStatusBar()
{
    statusBar();                                     //注释3
    new_Action->setStatusTip(tr("新建一个文件"));     //注释4
    open_Action->setStatusTip(tr("打开一个文件"));
    save_Action->setStatusTip(tr("保存当前文件"));  
}
```
>注释3：这里调用statusBar()来生产一个状态栏，这个函数同时返回一个指向QStatusBar类型的指针，这个函数和创建状态栏的函数很相似，QMainWindow自带状态栏，但默认是不创建的，需要创建时调用该函数即可。在我们这个例子中，由于只需要在状态栏上显示信息，默认的状态栏足以，所以对于返回的指针不需要做什么，但如果有需要额外的功能，可以将这个函数的返回值复制给一个QStatusBar*,然后在继续操作

>注释4： 这里使用了QAction的成员函数setStatusTip()来生成状态栏上的信息，以“新建”为例，当鼠标悬停在“文件”菜单上的“新件”选项是，程序底部的状态栏上就会显示信息“新建一个文件”。这里我只设置了3个选项的状态信息，你也可以根据程序的具体需求添加其他QAction选项的状态信息

## 快捷键

对于一个程序来说，快捷键是必不可少的一部分，很多时候使用键盘会比使用鼠标更加方便，Qt也提供了一套关于快捷键的方法，以我们现在制作的这个程序为例，菜单中的“新建”，“保存”，“打开”等，设置快捷键会更加方便使用。而QAction其实已经考虑到了这一点，最简单的方法就是调用QAction的成员函数setShortcut()来实现快捷键的功能

但这里遇到一个问题，相同的快捷键在不同平台下功能可能不同，例如windows系统的Ctrl+c是复制的快捷键，但在Linux系统下Ctrl+c表示终止程序运行，为了解决不同平台快捷键冲突的问题，Qt提供了一个类QKeySquence来解决次问题。

首先在ReadTxt.h中添加一个私有函数用于快捷键的创建void setHotKey();具体实现如下
```c++
void ReadTxt::setHotKey()
{
    new_Action->setShortcut(QKeySequence::New);   //注释5
    copy_Action->setShortcut(QKeySequence::Copy);
    paste_Action->setShortcut(QKeySequence::Paste);
}
```
注释5：以“打开”为例，其实这样里可以写成setShortcut("Ctrl+O")来实现功能，但就如前文所述，不同平台的快捷键是不完全一样的（虽然Ctrl+O各平台都有相同功能，但不是每个快捷键都这样），所以用QKeySequence类实现比在代码中写死要更加灵活，当代码需要跨平台是更加如此。QkeSequence提供了大量的快捷键，内容太多无法在这里全部列出，可以在Qt Assistant中查询该类，看看里面是否有你需要的快捷键
            
              
到这里我们完成了记事本程序的大部分界面制作，下章开始我们将实现他的各项功能，这里再次给出ReadTxt程序到目前为止的构造函数的完整代码
```c++
ReadTxt::ReadTxt(QWidget* parent):QMainWindow(parent)
{
    createAction();
    createMenu();
    createMenuBar();
    setActionPix();
    createToolBar();
    createStatusBar();
    setHotKey();
    editor_TextEdit = new QTextEdit;
    setCentralWidget(editor_TextEdit);
    findWordsDialog = null;
    setWindowTitle("记事本");
    connectSignalAndSlot();
}
```