## QGraphicsItem

前面说过QGraphicsItem是个虚基类，Qt提供了很多基础该类的类用于各种场景

    QGraphicsItem
        QAbstractGraphicsShapeItem
            QGraphicsEllipseItem
            QGraphicsPathItem
            QGraphicsPolygonItem
            QGraphicsRectItem
            QGraphicsSimpleTextItem
        QGraphicsItemGroup
        QGraphicsLineItem
        QGraphicsObject
            QGraphicsTextItem
            QGraphicsWidget
                QGraphicsProxyWidget
        QGraphicsPixmapItem

但如果需要的元素有些特殊要求，那上面这些类可能无法完全满足，这个时候就需要基础QGraphicsItem，去重新实现一个元素了。前面两章通过元素/场景架构完成了一个贪吃蛇游戏，但这个游戏还有些不足，首先，游戏以吃到10个食物为胜利条件，而在游戏中用户却不知道游戏到底进行到哪一步了，其次，游戏的界面有些单调，比如蛇的身体，如果有些色彩会好看不少，所以对上一章的游戏做些改进，大致上会是下面这个样子

![](https://github.com/jxf2008/blog/raw/master/pix/QtNotes/19-1.png)

从图上可以看出，每个食物上多了一个数字，这样可以提示用户游戏的进度，同时蛇的身体有了色彩上的变化，而实现这些功能，需要子类化QGraphicsItem。Qt提供了大量的QGraphicsItem的子类以供我们使用，但有时候出现要求比较特殊，Qt的默认类没办法满足我们的需求时，就必须子类化QGraphicsItem来实现

## 自定义食物

首先看食物，上一章的食物使用的是QGraphicsRectItem,这里将会用一个自定义的FoodItem类来代替他，FoodItem继承自QGraphicsItem，QGraphicsItem里有两个纯虚函数需要实现.,首先看下FoodItem的头文件
```c++
class FoodItem : public QGraphicsItem
{
private:
    int numberInt;   //注释1
public:
    FoodItem(int nu , QGraphicsItem* parent = 0);
    void paint(QPainter* painter, const QStyleOptionGraphicsItem* option, QWidget* widget);   
    QRectF boundingRect()const;   //注释2
    QPainterPath shape()const;  //注释3
    void updateNumber(int nu);  //注释4
};
```
+ 注释1 该值用于记录当前为第几个食物，既食物上显示的数字
+ 注释2 paint()和boundingRect()这两个是必须重写的纯虚函数
+ 注释3 这个函数用于显示外形，关于外形和外框稍后再述，这里这个函数可以暂时不用实现
+ 注释4 这个自定义的函数用于更新食物上的数字

子类化QGraphicsItem有两个纯虚函数需要实现，其中paint()用于绘制自身，而boundingRect()则用于返回元素的外框,首先看下绘制函数的实现
```c++
void FoodItem::paint(QPainter* painter, const QStyleOptionGraphicsItem* option, QWidget* widget)
{
    Q_UNUSED(option)   //注释5
    Q_UNUSED(widget)
 
    painter->setBrush(QBrush(Qt::yellow));
    painter->drawRect(1,1,MAP_SIZE_SNAKE-2,MAP_SIZE_SNAKE-2); //注释6
 
    painter->setPen(QPen(QColor(Qt::red)));
    QFont ft;
    ft.setPointSize(15);
    painter->setFont(ft);　　//注释7
    painter->drawText(QRect(1,1,MAP_SIZE_SNAKE-2,MAP_SIZE_SNAKE-2),Qt::AlignCenter,QString::number(number_int));
}
```
+ 注释5 该函数不需要使用option和widget这两个参数，这里使用Q_UNUSED宏来避免编译器出现各种warning
+ 注释6 这里绘制的区域比游戏地图中的格子略小，这么做是为了方便后面的碰撞检查
+ 注释7 这里设置了字体的大小

然后是boundingRect()和shape()函数的实现
```c++
QRectF FoodItem::boundingRect()const
{
    return QRectF(0,0,MAP_SIZE_SNAKE,MAP_SIZE_SNAKE);
}

QPainterPath FoodItem::shape()const
{
    QPainterPath p;
    p.addRect(1,1,MAP_SIZE_SNAKE-2,MAP_SIZE_SNAKE-2);   //注释8
    return p;
}
```
+ 注释8 关于一个item的外框和外形，就这个类来说并没太大区别，需要注意的是，外框的返回值是QRectF，也就是说一个item的外框只能是个矩形，而外形的返回值是QPainterPath，这说明外形可以是个复杂的形状，而外框只能是个矩形，关于外框和外形的关系，在稍后的SnakeItem类中会进一步说，应为对于FoodItem来说，外形和外框是一致的，外形比外框的区域小一点点也只是为了后面的碰撞函数做准备，另外需要说明的一点是外形（shape)和外框（boundingRect)这两个名字是我起的，单纯为了方便描述为题

最后是updateNumber()函数，主程序每次更新食物位置前需要调用该函数来跟新数字，具体实现很简单
```c++
void FoodItem::updateNumber(int nu)
{
    numberInt = nu;
}
```

## 自定义蛇

到这里为止可以使用FoodItem来取代，假下来需要使用SnakeItem类来取代QGraphicsPathItem,这里同样直接继承自QGraphicsItem类，先看下头文件
```c++
class SnakeItem : public QGraphicsItem
{
private:
    QList<GridPoint> snakePaths_List;
public:
    SnakeItem(QGraphicsItem* parent = 0);
    void paint(QPainter* painter, const QStyleOptionGraphicsItem* option, QWidget* widget);
    QRectF boundingRect()const;
    QPainterPath shape()const;
    void setPath(const QList<GridPoint>& newPath);　　　//注释9
};
```
+ 注释9 QGraphicsPathItem继承QGraphicsItem的时候添加了一个函数setPath(),而我们实现的SnakeItem类需要一个类似功能的函数，所以这里就直接命名为setPath()，但这个函数的参数和QGraphicsPathItem提供的setPath()完全不同

接下来是绘制函数的实现
```c++
void SnakeItem::paint(QPainter* painter, const QStyleOptionGraphicsItem* option, QWidget* widget)
{
    Q_UNUSED(option)
    Q_UNUSED(widget)
 
    int colors = 1;
    for(auto A :snakePaths_List)
    {
        QRect rc(A.x*MAP_SIZE_SNAKE,A.y*MAP_SIZE_SNAKE,MAP_SIZE_SNAKE,MAP_SIZE_SNAKE);
        painter->setBrush(QBrush(QColor(colors*10,colors*2,colors*15)));     //注释10
        painter->drawRect(rc);
        ++colors;
    }
}
```
+ 注释10 绘制函数很简单，蛇的身体是由诺干个连续的方块构成，绘制函数就对这些方块区域逐个绘制，这样蛇的颜色就会变成彩色，这里只是为了演示所以演示弄的很简单（淡出的递减），如果你喜欢也可以设置成变的颜色

接下来就是略显混淆的外框（boundingRect()）和外形（shape()）函数了
```c++
QRectF SnakeItem::boundingRect()const
{
    int maxX = snakePaths_List.first().x;
    int maxY = snakePaths_List.first().y;
    int minX = maxX;
    int minY = maxY;
    for(auto A : snakePaths_List)
    {
        if(maxX < A.x)
            maxX = A.x;
        if(maxY < A.y)
            maxY = A.y;
        if(minX > A.x)
            minX = A.x;
        if(minY > A.y)
            minY = A.y;
    }
    int X = minX*MAP_SIZE_SNAKE;
    int Y = minY*MAP_SIZE_SNAKE;
    int W = (maxX-minX+1) * MAP_SIZE_SNAKE;
    int H = (maxY-minY+1) * MAP_SIZE_SNAKE;
    return QRectF(X,Y,W,H);       //注释11
}
 
QPainterPath SnakeItem::shape()const
{
    QPainterPath p;
    for(auto A : snakePaths_List)
        p.addRect(QRectF(A.x*MAP_SIZE_SNAKE,A.y*MAP_SIZE_SNAKE,MAP_SIZE_SNAKE,MAP_SIZE_SNAKE));  //注释12
    return p;
}
```
+ 注释11 这里返回一个简单的矩形

+ 注释12 这里需要返回一个复杂的QPainterPath，等于蛇的身体

关于**外框**和**外形**的区别，可以参照下图，以蛇为例，黄色区域就是**外框**，所以在boundingRect()函数中需要计算所有坐标的最大／最小值，即上下左右四个极值,通过这四个值（上下左右）形成的区域就是蛇的**外框**，而**外形**就比较好理解了,所能看到的拥有各种形状的蛇的身体就是外形.

![](https://github.com/jxf2008/blog/raw/master/pix/QtNotes/19-2.png)

另外需要注意的是**外形**的区域不能位于**外框**之外，否则就无法显示出来

对于前面的FoodItem来说，由于**外形**和**外框**一致，如果不需要使用稍后使用的碰撞函数的话完全可以不用实现shape()函数，之所以实现shape()函数并且是的食物的外形比外框略小，是为了后面碰撞函数服务。但对于像SnakeItem这样有着复制外形的item来说，他们的外框和外形并不一直，所以需要额外实现shape()函数来获得item的外形。

最后是setPath()函数的实现
```c++
void SnakeItem::setPath(const QList<GridPoint>& newPath)
{
    snakePaths_List.clear();
    snakePaths_List = newPath;
    //update();   注释13
}
```
+ 注释13 到这里我们实现了SnakeItem类，如果直接替换条游戏中原来的QGraphicsPathItem类会在显示上出现状况，出现这种情况的原因是，每当当蛇移动时会调用setPath()函数来重置蛇的路径（身体所在区域），必须刷新item的外形，然后机智的我就在setPath()函数里加上一句update();希望调用item的paint()函数来实现刷新item外形的作用，实际操作确实完全无效，对于QGraphicsItem来说，他的update()函数无法调用自己的paint()函数，也就是说无法更新item的形状，要更新item，必须调用QGraphicsScene->update();scene会更新在他上面的所有item，即调用位于scene的所有item的paint()函数。

最后是碰撞函数，最初使用的是判断食物和蛇的坐标是否相等来判断蛇是否吃到（碰撞）到食物，对于这个例子来，这样做并没有什么不妥，甚至非常方便，但一旦item的外形比较复杂时，使用坐标判断就比较麻烦了，QGraphicsItem提供了专门的碰撞函数来判断碰撞
```c++
virtual bool collidesWiteItem(const QGraphicsItem *other, Qt::ItemSelectionModemode = Qt::IntersectsItemShape) const
virtual bool collidesWitePath(const QPainterPath &path, Qt::ItemSelectionModemode = Qt::IntersectsItemShape) const
virtual bool collidingItems(Qt::ItemSelectionModemode = Qt::IntersectsItemShape) const
```
以上内容复制自Qt文档，函数的作用和他们的名字一样，需要注意的是Qt::ItemSelectionMode这个枚举值，他代表碰撞的类型
+ Qt::ContainsItemShape  当一个item的外形完全包含了另一个item
+ Qt::IntersectsItemShape  当两个item的外形有任意的重叠
+ Qt::ContainsItemBoundingRect　当一个item的外框完全包含了另一个item
+ Qt::IntersectsItemBoundingRect   当两个item的外框有任意的重叠

这就是前面为什么FoodItem的外形和外框一样，还需要重新实现shape()函数的原因，碰撞在主函数里碰撞检测使用的是检测外形，当没有实现shape()的时候，程序会把boundingRect()函数的返回值作为外形，所以处于谨慎的原则，还是重新实现了shape()函数.

本章完整示例代码请见：[贪吃蛇2.0](https://github.com/jxf2008/Snake/tree/Snake2.0)

