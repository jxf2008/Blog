## MVC

MVC(Model View Control)是在前一章里提到的模型/视图的概念，其实就是将数据和显示分开，这样在处理不同结构类型的数据时有着极大的方便。这一章将主要演示模型/视图结构带来的便利。

如果对于模型/视图没有任何的概念，也没有任何关系，这一章将通过一个例子演示下模型与视图的关系。这个例子将会用到前面有关数据库的内容，这里任然使用sqlite3作为例子。

为了实现这个例子，需要新建一个Sqlite3的数据库文件，里面包含了超过2张表，然后往这两种表里插入若干的数据，但插入的数据请不要过多，本章的例子不能处理大量的数据

## 显示表

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/QtNotes/23-1.png)

这是一个很简单的数据库查看软件，通过这个程序可以显示制定数据库里的全部数据。首先看下这个程序界面，这个程序有两张“表”，左边的是数据库里所有的表的名字，而右边则是每张表的具体内容，当用户点击左边的某一个表名的时候，右侧便会显示用户选择的表的数据。对于sqlite3数据库来说，有一张默认表，sqlite_master,会记录数据库里所有的表名（以及表其他的相关信息），所以我们要做的就是在程序界面的左边显示sqlite_master这张表，而在右侧显示其他表。

如果用上一章的内容来完成这个程序，对于左侧的表，尚可以使用QListWidget来完成，通过SQL语句查询所有表名后把数据传递给QListWidget，但对于右侧的表格就麻烦了，对于这种表格，自然想到的是使用QTableWidget，但问题是你不知道数据库中的表，每张表究竟有几列，折中的办法是假设数据库中表的列不会超过100列，然后把QTablwWidget的列数设为100，这样虽然可以显示全部表，但由于大多数表的列数不会有100列，所以在大多数情况下，这会造成大量资源的浪费。而且这里我们假设表的列不会超过100，虽然在数据库的表的设计中，一般会建议表的列数不要超过100，但这也只是个建议，如果遇到超过100列的表，那就会出现未知的问题。

这里可以看出问题的所在了，数据的结构千变万化，我们需要应对的情况太多，需要一种能够应付各种情况的解决办法，对于我们这个例子，解决的办法就是用QSqlTableModel+QTableView的组合来代替QTableWidget。

首先是QSqlTableModel类，这个类用于加载数据库中的某章表的数据，而QTableView用于显示QSqlTableModel，这样做的好处是无论我们怎么样改变QSqlTableModel的数据，QTableView总能正确的显示他。

## 实现

首先看下程序的头文件
```c++
class LookTable : public QDialog
{
    Q_OBJECT
private:
    QSqlDatabase db_Database;
 
    QTableView* tableName_TableView;
    QTableView* tableData_TableView;
 
    QSqlTableModel* tableName_TableModel;
    QSqlTableModel* tableData_TableModel;     //注释1
 
    QLineEdit* databaseFilePath_LineEdit;
 
    QPushButton* chooseFile_PushButton;
public:
    LookTable(QWidget *parent = 0);
    ~LookTable();
private slots:
    void setNewTableData(const QModelIndex& indexs);　　　//该函数用于切换表
    void changeDatabase();　　　　　　　　　　　　　　　　　　//该函数用于改变数据库
};
```
+ 注释1 为了正确的显示sqlite_master和自定义的表，这里使用了两组QSqlTableModel和QTableView的组合

然后是程序的构造函数
```c++
const QString DEFAULT_DATABASE = "E:/QtBlog/p23/sqliteFile/StoneData.db";  //注释2
 
LookTable::LookTable(QWidget *parent)
    : QDialog(parent)
{
    QSqlDatabase db_Database = QSqlDatabase::addDatabase("QSQLITE");
    db_Database.setDatabaseName(DEFAULT_DATABASE);
 
    tableName_TableView = new QTableView;
    tableData_TableView = new QTableView;
 
    tableName_TableModel = new QSqlTableModel;
    tableData_TableModel = new QSqlTableModel;
 
    databaseFilePath_LineEdit = new QLineEdit;
 
    chooseFile_PushButton = new QPushButton("...");
 
    tableName_TableModel->setTable("sqlite_master");  //注释3
    tableName_TableModel->select();　　　　　　　　　　　　　//注释4
    QString defaultTableName = tableName_TableModel->record(0).value("name").toString();　//注释5
    tableData_TableModel->setTable(defaultTableName);
    tableData_TableModel->select();
    tableName_TableView->setModel(tableName_TableModel);
    tableData_TableView->setModel(tableData_TableModel);  //注释6
    tableName_TableView->setSelectionBehavior(QAbstractItemView::SelectRows);　//注释7
    tableName_TableView->setEditTriggers(QAbstractItemView::NoEditTriggers);
    tableData_TableView->setEditTriggers(QAbstractItemView::NoEditTriggers);　　//注释8
 
    tableName_TableView->setFixedSize(500,800);
    tableData_TableView->setFixedSize(800,800);
 
    databaseFilePath_LineEdit->setText(DEFAULT_DATABASE);
    databaseFilePath_LineEdit->setAttribute(Qt::WA_TransparentForMouseEvents);
 
    QHBoxLayout* view_Layout = new QHBoxLayout;
    view_Layout->addWidget(tableName_TableView);
    view_Layout->addWidget(tableData_TableView);
    QHBoxLayout* choose_Layout = new QHBoxLayout;
    choose_Layout->addWidget(databaseFilePath_LineEdit);
    choose_Layout->addWidget(chooseFile_PushButton);
    QVBoxLayout* main_Layout = new QVBoxLayout;
    main_Layout->addLayout(view_Layout);
    main_Layout->addLayout(choose_Layout);
    setLayout(main_Layout);
    main_Layout->setSizeConstraint(QLayout::SetFixedSize);
 
    connect(tableName_TableView,SIGNAL(clicked(const QModelIndex&)),this,SLOT(setNewTableData(const QModelIndex&)));            //注释9
    connect(chooseFile_PushButton,SIGNAL(clicked()),this,SLOT(changeDatabase()));
}
```
+ 注释2：这里是默认数据库文件的路径，编译程序前请把这个路径改成你的数据库的文件的路径

+ 注释3：在成功连接数据库够，QSqlTablwModel可以通过setTable()函数来设置表名，从而使的该模型绑定指定表的数据，左侧我们需要显示所有表的名字，所以模型绑定表sqlite_mastre。

+ 注释4：select()函数用于查询表的数据，模型在绑定一张表后，需要查询表才能获得数据，select()函数实际上使用SELECT语句来查询表的全部数据。

+ 注释5：在使用select()函数后，模型已经获得了他绑定的表的数据，record()函数返回一个QSqlRecord对象，这个对象可以理解为数据的查询结果，前面的select()函数使用SELECT语句查询了表的数据，所以record()函数可以看做SELECT语句的返回结果，程序开始的时候右侧显示的是第一张表的内容，所以这里去查询结果的第一条，即调用record(0);

+ 注释6：在模型获得了数据后就可以用视图来显示了，这里通过视图和模型结合就可以正确的显示数据

+ 注释7：右侧的表我们只需要知道表名，所以我们设置用户点击视图时会选择整行。

+ 注释8：这里设定视图为不可编辑，QTableView默认是可编辑的，由于编辑数据会带来大量的问题，有关编辑数据可能会引起的问题以及解决办法会在下一章自定义模型中讲述，这里先暂不考虑编辑数据的问题。

+ 注释9：当用户用鼠标点击QTableView的时候他会发射信号clicked(const QModelIndex&),通过这个信号和参数（索引）就可以知道用户点击了哪张表，然后程序里自定义了一个槽和这个程序连接，在槽里改变右侧表的数据。

然后是改变右侧数据的槽函数
```c++
void LookTable::setNewTableData(const QModelIndex& indexs)
{
    if(!(indexs.isValid()))
        return;
 
    int rows = indexs.row();
    QString tableNames = tableName_TableModel->record(rows).value("name").toString();  //注释10
    tableData_TableModel->setTable(tableNames);
    tableData_TableModel->select();      //注释11
    tableData_TableView->setModel(tableData_TableModel);      //注释12
}
```
+ 注释10：用户点击了左侧的QTableView后，通过QModelIndex可以知道用户点击了第几行，然后就可以很容易查询到该行的数据（我们需要的是列"name"的数据）。

+ 注释11：在获得新的表名后，右侧的模型需要绑定新的表，并且查询表的数据。

+ 注释12：在查模型查询完数据后，用QTableModel将数据显示（跟新）出来。

这个槽函数最能体现模型／视图的优势，当数据有变动，QTableView总能正确的显示，反之当我们需要更改模型数据时，就不用担心显示的问题。模型/视图结构最大的特点就是将数据和显示分隔开来，减少两者之间的关联。大多数时候，以而为表格为例，虽然他们可以使用QTableWidget来显示，但使用模型＋QTableView的组合会极大的减少开发时遇到的问题。

关于模型，Qt提供了一些现成的模型方便使用，对于有特殊要求的数据就需要用到自定义的模型，关于自定义模型下章再述。这里列出了Qt提供的一些主要的模型.。

1. QStringListModel:一般用于处理字符串列表
2. QStandardItemModel:用于处理分层的数据结构
3. QDirModel:用于处理本地文件系统，前一章演示QTreeWidget的例子，也可以使用QDirModel+QTreeView来完成
4. QSqlQueryModel:大部分时间，会用于处理SQL语句查询结果
5. QSqlTableModel:用于处理数据库中制定表的数据.
6. QSQlRelationTableModel::用于处理带有外键的表。
7. QSortFilterProxyModel:为已有的模型设置过滤器，可以通过该模型对另一个模型排序/筛选
