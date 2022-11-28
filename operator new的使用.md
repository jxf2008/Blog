## ::operator new

对于很多初学者来说，C++的new接触的比较多，而::operator new就接触的比较少了。在开始之前，先简单的看下new
```c++
int* v = new int;
```
这样一条简单语句，new完成了两个工作，首先向系统申请一段内存，大小刚好可以存放一个int，第二步，在申请的内存中初始化一个int对象。由于new是c++内建的，程序员无法控制new的行为，但有些时候这就会引发一些问题，假设一家学校计划招收100名学生，但学校并不能确定能否招满，如果用new来实现这个功能，向系统申请可存放100个Student类对象的内存,初始化100个Student类，每招收到一名学生，就把一个Student对象复制一下。

假如学校今年招收了60名学生，那代码上需要调用Student类的默认构造函数100次，复制函数60次，析构函数40次，如果不巧Student类的这几个成员函数的开销比较大，那这种策略就显得有些得不偿失了，更有效的办法是把申请内存和创建对象分开，这里就需要用到::operator new了

## 创建和删除对象

为了演示::operator new和new的区别，先建立两个简单的类
```c++
class Number {
private:
	int n;
public:
	Number(int v) :n(v) { std::cout << n << "已经成功构建\n"; }
	~Number() { std::cout << n << "已经析构\n"; }
};

class Student {
private:
	Number* n;
public:
	Student(int v) { n = new Number(v); }
	~Student() { delete n; }
};
```
然后使用::operator new来创建一个对象
```c++
	Student* student = static_cast<Student*>(::operator new(sizeof(Student)));
    //申请一块内存，并没有生成对象

	new(student) Student(1);  
    //在指定的内存里生成对象

	::operator delete(student);
    //使用::operator delete来向系统返还申请的内存
```
这段代码用VS2019编译运行的结果为

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/operator_new/3.png)

很明显，对象student的析构函数没有被调用，这里存在内存泄漏。原因在于::operator delete并没有删除对象的作用，这是他和delete的重要区别，要想正确的析构student对象，必须在返还内存前显式的调用student的析构函数,即
```c++
student->~Student();
```
这是C++中极少数需要显式调用类的析构函数的情况

如果需要用::operator new申请多个对象的内存，可以用下列方法
```c++
Student* student10 = static_cast<Student*>(::operator new(sizeof(Student)*10));
//向系统申请可存放10个Student对象的内存
Student* student_tmp = student10;
Student* student_delete = student10;
//将申请的内存起始地址保存下


for (int i = 0; i < 10; ++i) {
	new(student10)Student(i + 1);
	student10 += 1;
    //在申请的内存上创建对象
}

for (int i = 0; i < 10; ++i) {
	student_tmp->~Student();
	student_tmp += 1;
    //从内存的起始开始，逐个调用对象的析构函数
}

::operator delete[](student_delete);
//向系统返还内存
```

## 确定创建对象的位置

使用::operator new比较容易出现的错误，是不在指定的内存创建对象，比如下列代码
```c++
Student* student = static_cast<Student*>(::operator new(sizeof(Student)));
//std::cout << "地址一：" << student << std::endl;
student =  new Student(1);
//重点：这里使用new生成对象
//std::cout << "地址二：" << student << std::endl;

student->~Student();
//std::cout << "地址三：" << student << std::endl;
::operator delete(student);
```
这断代码在VS2019和GCC7.3上都可以编译运行，并且编译器不会给出任何警告，在注释中的语句用于输出指针的值，如果取消掉注释，你可能认为这三个输出语句应该输出一个相同的值，因为他们都指向同一块内存，但实际的输出结果却是

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/operator_new/2.png)

这里的问题在于，“地址一”是使用::operator new向系统申请的内存的地址，指针student也指向改内存，但下一句代码里使用了new,前面提过new有两个作用，申请内存和创建代码，这句代码里new又申请了另一块内存同时创建了一个Student的对象，然后student指针指向new申请的内存，这里也解释了为什么“地址一”和“地址二”的输出值不一样。

而上述代码中“地址一”是由::operator new向系统申请的内存，由于student指针指向了别的内存，导致“地址一”最后都没能向系统返还