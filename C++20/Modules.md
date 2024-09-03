## 一个古老问题

首先看一段C++代码
```c++
#include <iostream>

int main(){
    using namespace std;
    cout<<"Come up and C++ me some time.";
    cout<<endl;
    cout<<"You won't regret it"<<endl;
    return 0;
}
```
这段代码是《C++ Primer Plus》的第一段示例代码，这是我初学C++时候写下的第一段代码，你的第一个C++程序很可能也是非常类似，当我照着书本敲下这些代码，然后点击“运行”，然后电脑上出现了一个黑框框，上面显示了代码里的文本。对于很多C++初学者来说，觉得自己仅仅写下了一段只有几行代码的程序，当然，C++的初学者在么认为没什么问题，但如果使用C++很久了，再回到这段代码时，就不能认为这“仅仅几行代码”。其实个程序非常的庞大，包含了超过一万行（对于初学C++的我来说，一万行的代码是个天文数字）的代码，代码的具体行数会根据不同的编译器有所不同，但我现在用的两个编译器，编译这段代码的时候都超过了一万行，具体几行没有数，因为我数到一万的时候就停下来了

之所以出现这种情况，是因为这段代码上面有个#include，虽然这只有一行，但如果你通过IDE点进该文件，发现该文件除了普通代码外，在最上面还有若干个include,然后再查看这些文件，情况也类似，这些文件都包含了一些普通的代码，然后最上面有若干个include,这有点像一个二叉树查找，总之，这些include的代码会被全部添加到这段“仅仅只有几行”的代码里，然后一起编译。这带来的问题分为两个方面，一个是编译时间编程，毕竟预期编译几行代码，但实际需要编译万行级别的代码；另一个便是编译后的文件体积增大，造成运行期时间变长。

在实际的项目中，也会出现类似的问题。比如很多C++项目都会把一些常量定义放在一个或几个.h文件里，这是一个好习惯，方便大型项目的代码管理。比如在一个关于机械设备的大型项目里，有个MachineType.h文件，用于定义某些机械的属性，该头文件里包含了数百个结构，枚举和常量的定义，这个文件目前有四千行的代码，现在项目需要添加一个新的类用于表示某种新的机械设备，该类的.h文件50行代码，而cpp文件有300行代码，这在整个工程里是个非常不起眼的类，但由于需要用到MachineType.h文件里定义的某个结构，于是在cpp文件里include了MachineType.h文件，于是cpp文件就从原来的300行增加到4300行。。。。。。而假设整个项目里一共有150个类需要用到这个MachineType.h文件，这150个类都要在其cpp文件里include这个MachineType.h文件，于是整个工程的代码变增加了150x4000行代码。。。。。。

C++还存在另一个从出生便带有的问题，便是模板。C++采用了和C语言一样的声明和定义分离的策略，但这套模式在模板上却无法实现，到目前为止，所有的模板都只能把声明和定义写在一个文件里，这个文件通常是.hpp，即.h和.cpp的结合。这个问题在实现一些类或者较复杂的函数时特别明显，很多类声明只有几十行，而定义文件却有几千行甚至更多。如果是非模板代码，只要#include几十行代码，即.h文件，而如果这个类是模板，那只能把几千行甚至更多的代码全部用#include了。最常见的就是标准库的各个类，这些类大部分是模板，比如上面的iostream文件里的类，还有常用的如std::list，std::vector等,也许程序只需要在某一行代码里使用到这个类，但不得不#include几千甚至几万行代码

从这里就看出，这个由include带来的问题，自C++诞生以来就一直存在，早期由于各种原因（很重要的一个原因是因为C++标准不属于某家商业公司，而是属于C++标准委员会，而该委员会的成员来自不同的商业公司，每次的标准制定，不同的委员往往会争执不休，这导致C++的很多标准的制定非常冗长<sup>引1</sup>），这个问题一直没能有一个有效的解决方案。直到C++20标准的发布，才终于有了一个解决方案，即C++20四大组件之一的Module。

## Hello Modules

在之前的C++标准，通常使用.h文件来存放声明，并在需要的地方使用include来包含该文件，而在C++20标准中，使用.ixx文件作为模块<sup>注1</sup>的声明文件，这取代了之前通常用于声明文件的.h文件，模块和C++一直以来的#include系统，最大的不同在于，某个文件里导入的模块代码不会被添加到该文件里，而原先的#include系统会把文件添加到目标文件里一起编译。

C++20使用了export和import这两个关键字来定义和导出Module，其中export在C++99/03标准中被用作模板的定义和实现的分离，但该标准后来被证明是个不靠谱的设计，当时几乎没有编辑器支持该关键字，因此在C++11标准中export被声明废弃，但保留作为关键字，现在到了C++20有了新的作用。

而import只有在导入模块时候才会视为关键字，这和override，final类似，在C++20标准下，定义一个名为import的函数，或者定义一个名为import的类都是合法的代码

首先看如何导出一个模块的<sup>注2</sup>
```c++
import <iostream>;

int main(){
    std::cout<<"Hello World";
}
```
这里可以看出使用import取代了#include,虽然仅仅是关键字不一样，但使用Module和include有一个重要的区别，即导入的Module不会被添加到编译单元，也就是说，这段代码才是真正意义上的“仅仅几行代码”的程序

接下来是自定义一个Module并且导出,第一步是在工程种添加一个Module文件，该文件默认的后缀是.ixx，而文件名称是合法的C++文件即可

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/C20/H02.png)
![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/C20/H03.png)

然后HelloModule的声明如下
```c++
//HelloWorld.ixx
export module HelloModule;

import <iostream>;

export void print_hello_module() {
	std::cout << "Hello Module" << std::endl;
}

export {
	void print_hello_world() {
		std::cout << "Hello World" << std::endl;
	}
}

void print_erro(){
    std::cout <<  "This is an ERROR.";
}
```
从上面代码里可以看出export的用法，首先将.ixx文件声明为HelloModule的Module,这里有两个注意点，一个和Java不同，Module的名称和文件名无关，没有强制Module必须和文件名相同，上面的代码改成export module FIRST;也完全没问题；另一个注意点是每个.ixx文件里只能有一个Module，如果有多个声明，则无法通过编译，编译器会提示“C2237 多个模块声明”

export的另一个用途是将模块内的某个声明是可以导出，这个必须显式声明，如果没有显示声明该定义为export，则该定义无法被导出。比如这个模块内，有个print_erro()函数，但函数并没有使用export,这是合法的代码，但稍后可以看到，该该函数无法被导出。

在自定义了一个Module后，看下如何在其他地方导出的
```c++
import <iostream>;
import HelloModule;

int main() {
	print_hello_module();
	print_hello_world();
	//print_error();
}
```
导出一个Module非常简单，使用import即可，如果取消注释，调用print_error()是无法通过编译的，编译器会提示“C3861 print_error: 找不到标识符”,因为该函数在Module中没有使用export关键字，因此无法被导出。

## Module的实现分离

之前的HelloModules使用的类似inline函数，并没有将实现分离，接下来演示如何通过Module来实现一个接口和实现分离的类，首先在工程里添加一个People.ixx文件用于的Module，接下来添加一个People.cpp文件用于类的实现。

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/C20/H04.png)

先看Module的声明
```c++
//People.ixx
export module People;

import <string>;

export class People {
private:
	std::string name;
	int         age;
public:
	People();
	People(const std::string& nm, int y);
	virtual ~People();
	virtual void print_info()const;
};
```
这和之前声明函数的Module差不多，类定义之前使用关键字import将该类声明为可以导出，然后是类的实现
```c++
//People.cpp
module People;

import <iostream>;

People::People():name("None"),age(0) {

}

People::People(const std::string& nm, int y) :name(nm), age(y) {

}

People::~People() {
	std::cout << name << " Is Dead, Age:" << age << std::endl;
}

void People::print_info()const {
	std::cout << "Name : " << name << std::endl;
	std::cout << "Age : " << age << std::endl;

}
```
由于.cpp文件是实现文件，因此函数实现前面不需要用export，但这里有个注意点，文件最上方使用的是module People;而不是import module People;这个是导出模块和模块实现文件的区别

People和之前的HelloModule使用完全一样

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/C20/H05.png)

## 使用子Module

对于大型的C++项目来说，代码的分类很重要，有助于项目和代码的组织管理。在模块中，可以非常方便的将一个模块设为另一个模块的子模块，这样不仅可以方便组织管理代码，而且可以根据需要导入指定的子模块，不用导入整个模块。

以上面的People类为例，需要通过继承该类来定义一个Student类，和之前的People类相似，在工程中添加了一个Student.ixx的Module文件，和一个Student.cpp的实现文件。

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/C20/H06.png)

这个类由于继承自People类，因此可以单独作为一个模块，也可以作为一个子模块放在People模块下，首先看下.ixx文件
```c++
export module People.Student;
import People; 

export class Student : public People {
private:
	int GPA;
public:
	Student(const std::string& nm, int y, int gpa);
	Student();
	~Student();
	void print_info()const override;
};
```
和People.ixx唯一的区别在于第一行，即该模块是People.Student,而不是Student。这里可以理解为声明该模块是People的一个子模块。

然后是.cpp文件
```c++
module People.Student;

import <iostream>;

Student::Student(const std::string& nm, int y, int gpa):People(nm, y),GPA(gpa){

}

Student::Student():People(),GPA(0){

}

Student::~Student() {

}

void Student::print_info()const {
	People::print_info();
	std::cout << "GPA : " << GPA << std::endl;
}
```
区别同样只有第一行

这样Student就变成了People的一个子模块，而不是一个单独的模块，当然Student是可以单独被导入的，只是导入的时候需要使用People.Student。

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/C20/H07.png)

这里有个#include和import的非常重要的区别，对于#include系统，如果一个文件A中有#include一个类People，那么在别的文件里只要#include "A"，就可以使用People类；但在Module系统中却不一样，在Student.ixx文件中，虽然导入了People模块，但在main.cpp文件中如果注释掉import People,即只导入People.Student，这个时候编译会报错“C2065	“People”: 未声明的标识符”；

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/C20/H08.png)


引1：《C++ Model Design》

注1：Module在C++20中，有翻译为模块，也有翻译为模组，还有其他的一些翻译，这里统一采用模块这个翻译

注2：目前VS2022将全部标准库都提供了一份模块方案，因此可以使用模块，也可以只用之前的include方案，其他的编译器可能没有提供标准库的模块方案，或者不完整。