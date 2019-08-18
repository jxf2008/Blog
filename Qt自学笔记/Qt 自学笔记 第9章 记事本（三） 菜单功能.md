## 编辑菜单

前面完成了记事本程序的界面制作，这一章将来实现这个程序的菜单上的各项功能。我们使用QTextEdit来作为记事本程序的中心窗体，这里有一个很大的便利就是QTextEdit提供了很多和编辑有关的函数，槽等，在需要的时候只需要直接调用即可，其中，撤销，恢复，复制，粘帖，剪切，全选在QTextEdit均有对应的槽来实现其功能，我们要做的就是把编辑菜单上的动作（QAction)和这些槽连接起来即可，在ReadMe.cxx文件中已经建立了一个用于链接信号与槽的函数ConnectSingalAndSlot(),现在只需要在这个函数里添加连接
```c++
connect(redo_Action,SIGNAL(triggered()),editor_TextEdit,SLOT(redo()));
connect(undo_Action,SIGNAL(triggered()),editor_TextEdit,SLOT(undo()));
connect(paste_Action,SIGNAL(triggered()),editor_TextEdit,SLOT(paste()));
connect(cut_Action,SIGNAL(triggered()),editor_TextEdit,SLOT(cut()));
connect(copy_Action,SIGNAL(triggered()),editor_TextEdit,SLOT(copy()));
connect(selectAll_Action,SIGNAL(triggered()),editor_TextEdit,SLOT(selectAll()));
```
关于QTextEdit的详细功能，有兴趣的可以查阅Qt Assistant

但QTextEdit并没有提供查询，删除这两个功能，这需要我们自己来实现，对于查询功能，必须对先去的查询对话框（前面完成的FindDialog)再次做一些改动，最初我们只是最做了一个对话框的界面，他只有一个点击“取消”关闭自身的功能,这次，为了实现记事本的查询功能，需要对这个对话框再次改动。

## 查询菜单

要实现查询对话框的查询功能，需要知道三个信息，查询的内容，是否区分大小写，查询顺序，这三个信息分别来自对话框上的QLineEdit和两个QCheckBox,接下来就是对FindDialog.h文件做些改动，首先添加一个findWords()的私有槽来获取信息，其次添加一个信号findWordDetail(const QString& , bool , bool),这个信号用于把查询文本的三个信息通过信号发射出去（即发射给记事本主程序）

在FindDialog.h文件中添加findWordDetail()信号
```c++
//......
signals:
    void findWordDetail(const QString& str, bool direction, bool caseSensitivity);  //注释1
private slots:
    void findIsEnabled(const QString& str); //注释2
    void findWords();
```
>注释1：这个是添加信号，他的三个参数分别对于查询内容，方向，大小写，这些详细信息将会和记事本程序的槽连接，稍后会实现记事本程序的槽

>注释2：还记得这个findIsEnabled()槽吗，在最初的程序中这个槽就已经被实现了，当查询框内容为空的时候，“查询”按钮不可用，当然在最初的设计中，这个槽被设计为共有的，主要因为最初的时候并不清楚这个操是否需要在对象外调用，现在可以明确的知道不需要了，所以把这个槽改回私有的。其实这里只是演示下软件设计的存在问题，很多程序在设计的时候就需要考虑到以后可能的改动，在设计之初就考虑这点可以减少很多以后的麻烦

接下来是实在FindDialog.cxx文件中实现这个槽
```c++
void FindDialog::findWords()
{
    bool caseSensitivity = matchCase_CheckBox->isChecked();     //注释3
    bool direction = goBack_CheckBox->isChecked();
    QString strs = findString_LineEdit->text();     //注释4
    emit findWordDetail(strs,direction,caseSensitivity);     //注释5
}
```
注释3：对于单选按钮QCheckBox，他的成员函数isChecked()返回对象是否被选择，返回结果是布尔值。

注释4：QLineEdit的成员函数text()返回对象的文本内容，返回类型为QString,如果QLineEdit内容为空，则返回一个空的QString,这些类的成员函数在Qt Assistant上均有详细的说明。

注释5：这里演示了使用关键字emit用于发射信号，其实"关键字"emit是个宏，Qt已经做了处理，当然理解为关键字也不会有什么问题

最后一步是在FindDialog的构造函数中将“查询”按钮和这个槽链接起来
```c++
connect(find_PushButton,SIGNAL(clicked()),this,SLOT(FindWords()));
```
这样，当点击“查询”按钮时，就会链接到槽FindWords()，然后这个槽（成员函数）获取对话框的文本内容，大小写，查询方向信息，然后把这3个信息以信号的方式发射出去

在完成了FindDialog的修改后，使得他能提供需要查询的内容的详细信息，然后就是修改记事本的主程序，使得他能接受这些详细信息并最终实现查询功能。在ReadTxt.h文件中，添加一个槽
```c++
void findWordInText(const QString& str , bool direction , bool caseSensitivity);
```
在ReadTxt.cxx文件中来实现这个槽
```c++
void ReadTxt::findWordInText(const QString& str , bool direction , bool caseSensitivity)
{
    bool findWord = false;
    if(direction == false and caseSensitivity == false)   //注释6
        findWord = editor_TextEdit->find(str);
    if(direction == false and caseSensitivity == true)
        findWord = editor_TextEdit->find(str,QTextDocument::FindCaseSensitively);
    if(direction == true and caseSensitivity == false)
        findWord = editor_TextEdit->find(str,QTextDocument::FindBackward);
    if(direction == true and caseSensitivity == true)
        findWord = editor_TextEdit->find(str,QTextDocument::FindCaseSensitively|QTextDocument::FindBackward);
    if(findWord == false)
        QMessageBox::information(this,tr("查询"),tr("无结果"),QMessageBox::Yes);   //注释7
}
```
>注释6：QTextEdit提供了一个成员函数find()来实现查询功能，他的原型是find(const QString&,QTextDocument::flags);其中枚举值QTextDocument::flags用于区分查询方式，如上面函数使用的值Qt::FindCasesitively和Qt::FindBackward用于表示区别大小写和查询方向，QTextDocument::flags全部值可以查询Qt Assistant，另外有一点注意的是，前面说过信号与槽的连接必须保证参数是一致的，否则无法传递对于的数据，这里的一致是区分const的，即信号Signals(const QString&)和槽Slots(QString&)连接，是无法传递QString的，因为这两个参数一个是const,一个是非const

>注释7：这里使用了QMessageBox提供的标准按钮，这个静态函数看样子有点复杂，但其实原型非常简单

```c++
QMessageBox::information(父对象指针，标题内容，信息内容，按钮);
```
以这个程序为例，当查询结束是，你希望这个消息框显示内容为“查询结束”，用是界面上有Yes和No两个按钮，那可以这样写
```c++
QMessageBox::information(this,tr("查询"),tr("查询结束"),QMessageBox::Yes|QMessageBox::No);
```
QMessageBox还提供了warning(),question(),critical()函数，他们有自己特点的图标，同时这些函数均返回点击的按钮值QMessageBox::StandardButton,这是个枚举值，可以通过返回值来判断用户点击了什么按钮，是Yes,No还是其他的按钮，要使用这些静态函数，需要在ReadTxt.cxx文件中添加头文件#include<QMessageBox>

这样就实现了记事本程序的查询功能

1.当点击编辑菜单的"查询"(QAction)选项后，查询对话框显示（第五章实现）
2.点击对话框的“查询”按钮，查询按钮通过信号连接到findWords()槽，这个槽获取对话框的详细信息并发射信号，把这些信息传递给主程序的槽findWordInText()
3.主程序的槽findWordInText()使用这些信息，调用QTextEdit的成员函数find()来完成查询功能

## 删除菜单
在完成查询功能后，还需要实现删除功能，在ReadTxt.h中添加一个私有槽deleteSelectText()然后在ReadTxt.cxx中实现这个槽的功能
```c++
void ReadTxt::deleteSelectText()
{
    editor_TextEdit->textCursor().removeSelectedText();    //注释8
} 
```
>注释8：QTextEdit的成员函数textCursor()返回编辑的文本，以QTextCursor的形式，当然说他是形式其实很不恰当，他是Qt的一个类，QTextCursor主要用于提供操作Access和QTextDocuments的接口，其中QTextDocuments是Qt自定义的一各类，用于把文本转化成QTextDocuments的格式来做进一步的详细处理。这里textCursor()返回前文本已经转化为QTextDocuments格式，这里调用接口removeSelectedText()就可以实现删除选中文本的动能。

## 日期菜单

然后是日期/时间功能，这个功能对应的槽是dateAndTime()，具体实现为
```c++
void ReadTxt::dateAndTime()
{
  editor_TextEdit->insertPlainText(QDateTime::currentDateTime().toString());    //注释9
} 
```

>注释9：QTextEdit的成员函数insertPlainText()用于在当前位置插入一个QString,QDateTime是Qt用于处理日期时间的类，这个类实际运用的不多，大多数时候会使用他的两个子类QTime和QDate。QDateTime的静态函数currentDateTime()用于返回一个当前时间，返回的类型便是QDateTime,QDateTime类有成员函数toString()可以很方便的将值转化为QString，其中转换成QString的时间日期格式是默认的，如果需要转化为特定的时间日期格式，可以查询Qt Assistant上对toString()函数的说明，该函数提供了一个默认参数用于指定输出的时间日期的格式.

到这里就完成了编辑菜单上剩余的功能，需要做的就是在connectSignalAndSlot()函数中添加连接
```c++
connect(findNext_Action,SIGNAL(triggered()),this,SLOT(showFindDialog()));
connect(delete_Action,SIGNAL(triggered()),this,SLOT(deleteSelectText()));
connect(dateAndTime_Action,SIGNAL(triggered()),this,SLOT(dateAndTime()));
```
