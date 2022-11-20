## 调用C++函数

对于C++代码如下
```c++
//Student.h
#define MYDDLL _declspec(dllexport)
extern "C" MYDDLL void __stdcall printInfo();
```
```c++
//Student.cpp
void printInfo() {
	std::cout << "这是一个单独的C++函数";
}
```
通过VS编译成Student.dll文件，然后新建一个C#工程，将Student.dll文件放入C#工程的~/bin/Debug,或者~bin/x64/Debug目录下，其中C#工程必须和.dll保持一种，64位.dll不能用于32位的C#工程
```c#
namespace C2{
    class HelloWorld{
        [DllImport("Student.dll")] public extern static void printInfo();

        static void Main(string[] args){
            printInfo();
            Console.ReadKey();
        }
    }
}
```


## 调用C++类

C++中有些类型无法在C#中使用，需要在C++中加以封装，再编译成.dll
```c++
//People.h
#include <string>

#define MYDDLL_PEOPLE _declspec(dllexport)

extern "C" class MYDDLL_PEOPLE People
{
private:
	std::string name;
	int age;
public:
	People();
	People(const std::string& nm, int y);
	virtual ~People();
	std::string getName()const;
	int getAge()const;
	virtual void printInfo()const;
};
```
```c++
//People.cpp
#include "People.h"
#include <iostream>

People::People() :name("None"), age(0) {

}

People::People(const std::string& nm, int y) : name(nm), age(y) {

}

People::~People() {

}

std::string People::getName()const {
	return name;
}

int People::getAge()const {
	return age;
}

void People::printInfo()const {
	std::cout << "姓名：" << name << std::endl;
	std::cout << "年龄：" << age << std::endl;
}
```
这是一个典型的C++类，然后通过继承People类，生成一个Student类
```c++
//Student.h
#include "People.h"

extern "C" class MYDDLL Student : public People{
private:
	std::string address;
public:
	Student();
	Student(std::string nm, int y, std::string addr);
	virtual ~Student();
	void printInfo()const override;
};

extern "C" MYDDLL void __stdcall student_construct_0();   //注释1
extern "C" MYDDLL Student* __stdcall student_construct_3(const char* nm, int y, const char* addr);  //注释2

extern "C" MYDDLL void student_printinfo(const Student* student);   //注释3
```

+ 注释1 由于无法在C#中直接使用c++类的成员函数，因此需要将C++类的成员函数加以封装成普通函数

+ 注释2 C#中无法调用std::string,因此需要使用char*,而c++中的char*类型可以对应C#中的string类型

+ 注释3 c#中无法直接使用c++的类，因此所有需要返回自定义类。或者把自定义类作为参数的，都需要把类对象封装位指针，这样可以对应C#中的IntPtr类型

```c++
//Student.cpp
#include "Student.h"
#include <iostream>

Student::Student():People(),address("None"){

}

Student::Student(std::string nm, int y, std::string addr) : People(nm, y), address(addr) {

}

Student::~Student() {

}

void Student::printInfo()const {
	People::printInfo();
	std::cout << "地址：" << address << std::endl;
}

void printInfo() {
	std::cout << "这是一个单独的C++函数";
}

void student_construct_0() {
	Student A = Student();
	A.printInfo();
}

Student* student_construct_3(const char* nm, int y, const char* addr) {
	Student* A = new Student(nm,y, addr);
	A->printInfo();
	return A;
}

void student_printinfo(const Student* student) {
	student->printInfo();         //注释4
}
```

+ 注释4 这里封装了C++类的一个成员函数，参数是自定义类的指针。其实在C#中调用C++类，还有个办法是用C#重新实现C++类，但这样有两个困难，第一，C++类库较大，重新使用C#实现工程量太大，第二，C++类库如果是第三方的，会遇到闭源类库，无法获知C++类的结构。基于这两点，一般不使用重新实现C++类这种方法

最后是C#中调用
```c++
namespace C2{
    class HelloWorld{
        [DllImport("Student.dll")] public extern static void student_construct_0();
        [DllImport("Student.dll")] public extern static IntPtr student_construct_3(string nm, int y, string addr);
        [DllImport("Student.dll")] public extern static void student_printinfo(IntPtr student);

        static void Main(string[] args){
            student_construct_0();
            IntPtr student = student_construct_3("April", 25, "苏州");
            student_printinfo(student);
            Console.ReadKey();
        }
    }
}
```