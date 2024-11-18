## jthread

对于现在编程来说，多线程往往是必须的，在C++11标准中，标准库提供了std::thread类来实现多线程功能，但由于各种原因，特别是std::thread本身的一些缺点，导致很少有人使用他，而在C++20中，标准库提供了std::jthread来替代原有的std::thread，无论新的jthread还是原有的thread，在使用上非常类似unix的pthread。

```c++
#include <thread>
#include <chrono>
#include <iostream>

//一个睡眠1秒后打印线程ID的函数，该函数将被放入子线程中执行
void print_thread_id(int intervalSec);

int main() {
	std::cout << "Main Thread's ID : " << std::this_thread::get_id() << std::endl;
	int intervalSec = 1000;
	std::jthread childThread(print_thread_id, intervalSec);  //创建并启动线程
	std::cout << "Main Thread Is End." << std::endl;
}

void print_thread_id(int intervalSec) {
	std::chrono::milliseconds sec(intervalSec);
	std::this_thread::sleep_for(sec);
	std::cout << "Current Thread's ID : " << std::this_thread::get_id() << std::endl;
}
```
std::jthread的使用非常简单，创建一个std::jthread对象，第一个参数为函数指针，通常是需要在子线程内进行的任务，而剩余的参数则是该函数指针的参数。

当std::jthread对象创建时，该线程即刻开始执行，并没有某些类库中，类似run()或者start()这种显示启动的功能。

该程序执行结果为

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/C20/thread1.png)

从结果上可以看出，主线程已经结束，而子线程则在大约一秒后结束。

## 停止线程

在多线程的编程中，在某个特定的情况下提前终止正在执行的线程，是个非常常见的需求。比如为了读写一个较大的本地文件，该功能被放入一个子线程中进行执行，在尚未完成的情况下，一个优先级更高的需要读取该文件，这种情况下就需要提前终止子线程的任务。在std::thread中，要妥善的执行这个操作非常麻烦，这也是很多人不愿意使用std::thread的原因之一。而在C++20中，提供了和std::jthread相关的std::stop_token来实现这个功能。

对于任何一个子线程的停止，有两个最基本的要求，一是停止正在执行的任务，而是合理的资源释放，确保没有内存泄漏等问题，下面是一个模拟读些大型文件的函数，该函数用一个无限循环来模拟正在读取文件
```c++
void read_file(std::stop_token token, int threadNu) {
	int* ptr = nullptr;
    ptr = new int(0);   //模拟申请资源

	while (!token.stop_requested()) {
		int count = 0;
		while (count < 100) {  //无限循环模拟正在读取文件
			++count;
			if (count == 99)
				count = 0;
		}
	}

    delete ptr;    //模拟释放资源，如果直接中断线程，则无法正确释放资源
	ptr = nullptr;

	std::stop_callback callBack(token, [&]() {
		std::cout << "Release Resource From." << std::to_string(threadNu) << std::endl;
		if (ptr != nullptr)
			delete ptr;
		});
}
```
这个read_file()函数和之前的函数，最大的区别就是第一个参数是std::stop_token，带有这个参数的函数可以被终止，具体如何终止该线程稍后介绍，目前需要知道的是，如果线程被终止，则token.stop_requested()的返回值会变为false。

这里使用了new和delete来模拟资源的申请和释放，显然如果该read_file()函数在执行的过程中被终止，会出现内存泄漏。为例能在线程终止前正确的释放资源（或者其他一些必须在线程终止前做的工作），c++20提供了std::stop_callback类来实现这项功能，该类的构造函数有两个参数，一个是std::stop_token，另一个是匿名函数，当线程终止的时候会调用该匿名函数。

对于一个线程来说，如果有多项工作需要在线程结束前完成，可以实例化多个std::stop_callback，但需要注意的是，这些实例化的std::stop_callback，在线程结束时，被调用的顺序并不是他们被创建的顺序，而是取决于系统的调度。

接下来看下线程如何终止的
```c++
int main() {
	std::jthread thread1(read_file, 1);
	thread1.request_stop();  //直接调用成员函数request_stop()
	std::shared_ptr<std::jthread> ptr(new std::jthread(read_file, 2));  //调用析构函数
}
```
该程序运行结果为

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/C20/thread2.png)

在主函数里开启了两个线程，这两个线程内执行的是一个无限循环函数（用于模拟读取较大的文件），但这两个线程都立刻终止了。第一个终止是调用std::jthread的成员函数request_stop()，该函数被调用后，线程内std::stop_token的成员函数stop_requested()的返回值为false，因此在线程内可以根据该返回值来决定释放停止正在执行的任务

另一个终止线程的方法是调用线程的析构函数，thread2在创建的时候被放入了智能制造std::shared_ptr中，当主函数结束时，thread2离开了作用域，智能指针就会调用该对象的析构函数，而在std::jthread的析构函数中，也会调用std::jthread的成员函数request_stop()，从而达到停止线程的作用


## std::async

对于之前介绍的std::jthread，提供了多线程的支持，但std::jthread也存在也些不足，第一，子线程在创建的时候就会启动，而在很多实际情况下，线程需要等待一段实际再启动，比如一个读写文件的任务，创建后需要判断下目标文件是否正在被使用，如果有个更高优先级的线程在使用该文件，那该任务就需要等待其他线程结束后再启动；第二，对于一个任务是否需要放入子线程，需要根据实际情况来决定，比如读取文件时，先要判断下文件的大小，如果该文件非常的小，那单独开启一个线程去执行该任务就显得浪费了；第三，std::jthread对于线程的返回结果处理不是很好，虽然可以通过std::stop_callback来获取结果，但很多时候，我们需要一种比较简单，直接的方式来获取线程的结果。

C++为此提供了另一种多线程方式，即std::async，该功能可以让用户决定何时开启线程，任务是否放置于子线程中，同时通过std::future来简单直接的获取子线程中的结果。

假设有这样一个任务，需要判断一个数是否为质数，如果该数非常小，则没必要开启一个单独的线程来执行任务，但如果该数非常的巨大，那将任务放入子线程中执行是个非常明知的选择。对于这样一个任务，使用std::async会更加的合适。要使用std::async和std::future，需要头文件fucture。

```c++
#include <future>
#include <iostream>
#include <thread>
#include <string>

bool is_prime_number(int v, const std::string& threadName);

int main() {
	
	int A = 97;
	int B = 100;
	std::cout << "Main Thread ID : " << std::this_thread::get_id() << std::endl;

	//创建任务
	std::future resFutureA = std::async(std::launch::async, is_prime_number, A, "A");
	std::future resFutureB = std::async(std::launch::deferred, is_prime_number, B, "B");

	std::cout << "-----------" << std::endl;
	bool resA = resFutureA.get();  //开始执行任务
	bool resB = resFutureB.get();
	std::cout << std::to_string(A) << ":" << resA << std::endl;
	std::cout << std::to_string(B) << ":" << resB << std::endl;
}

bool is_prime_number(int v, const std::string& threadName) {
	std::cout << threadName << " ID :" << std::this_thread::get_id() << std::endl;
	bool res = true;
	for (int i = 2; i < v - 1; ++i) {
		if (v % i == 0) {
			res = false;
			break;
		}
	}
	return res;
}
```
首先，std::async函数有三个参数，第一个参数是个枚举值，用于控制目标任务在主线程还是子线程内执行，通过该枚举值，用户可以控制任务是否在子线程内进行或者交给操作系统判断。

| 枚举值 | 功能 |
|:----:|:----:|
|std::launch::async|在子线程内执行|
|std::launch::deferred|在主线程内执行|
| OR | 由操作系统决定|



其次std::async函数返回值是一个std::future，这段代码里使用了该类的get()函数，该函数有两个作用，第一个启动任务，也就是说std::async创建的时候，任务不会立刻启动，而是通过std::future的get()函数来启动的，这给了用户合适启动的决定权；第二个作用就是返回线程的执行结果。

该示例代码运行结果

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/C20/thread3.png)

从运行结果上可以看出，“线程B”的ID和主线程的ID是一样的，也就是说，任务B是在主线程中执行的，而任务A则是不同的线程ID，说明任务A实在另一个单独的线程里执行的

另外通过分割线的打印可以看出，在调用std::future的get()函数之前，任务并没有开始

## mutex

在多线程环境中，对于资源的使用是一个非常棘手的问题，就如前面之前提到的，当一个线程需要读写一个文件时，需要判断该文件是否正在被使用，或者一个线程正在读些某个文件，而此时另一个优先级更高的线程需要读取该文件，等等。这些情况往往根据不同的实际情况会变得非常复杂，但最基本的需求通常由两个，一个是在一段时间内，一个资源，比如一个文件或一个buff区域，只能被一个线程使用；第二个是确保线程某些操作能够完成，比如一个线程内正在执行100次的循环，在执行至50次时需要中断该线程，需要确保把剩余的循环次数执行完毕。和其他大多数语言一样，C++也是采用锁的方式来实现这些功能，相关的类都位于头文件mutex内

首先看一个简单的，具有读写功能的类，为了简化线程以外的代码，这个类使用读取一个数组来代替本地文件，同时用休眠的方式来模拟读取本地文件需要的时间
```c++
// .h
class FileIO{
private:
	int* d;   //数组，用于模拟本地文件
	int dataLen;
	bool allowRead;  //标记是否可以读
public:
	FileIO(int* data, int len);
	~FileIO();
	void read();
	void write();
};
```
```c++
//.cpp
void FileIO::read() {
	if (allowRead) {
		for (int i = 0; i < dataLen; ++i)
			std::cout << "第" << std::to_string(i + 1) << "个数为：" << *(d + i) << std::endl;
	}

}

void FileIO::write() {
	//每次写之前休眠1秒，用于模拟写入时间消耗
	std::chrono::microseconds interval(1000);  

	for (int i = 0; i < dataLen; ++i) {
		std::this_thread::sleep_for(interval);
		*(d + i) = i;
		std::cout << "第" << std::to_string(i + 1) << "个数已经完成写入：" << *(d + i) << std::endl;
	}
	allowRead = true;
}
```
上面的代码，主要read()和wirte()函数，如果在单线程内执行没什么问题，先执行wirte()，再执行read()。但如果这两个函数在两个不同的线程内执行（假设这两个线程分别叫writeThread和readThread），就会出现两个问题。

首先read()开始执行时，allowRead的值为false，因为次数write()函数还没执行完成，这会导致read()不去读取数据而直接结束。基于此，我们希望能够readThread先停止读取数组内容，直到writeThread完成后再去读取数组

其次，如果由于writeThread通过一个循环来执行写的功能，但考虑到可能在循环尚未完成的时候就有一个优先级更高的线程需要读写这个数组。此时需要writeThread能够执行完这个循环后，再停止wirteThread。

C++对此提供了mutex类来实现加锁，包括资源的占用，将多行代码合并为一个原子操作，而mutex的使用非常简单，只需要将需要进行原子操作的代码放入一个作用域（用大括号来限定），然后在这个作用域的第一行代码进行加锁，这样这个作用域就变成一个原子操作，类似下面的代码
```c++
void File::write(){
	{  //作用域，该作用域内的操作为原子操作
		std::unique_lock lock(mutex);  //加锁
		//write operate..
	}
}
```
其中mutex是在类定义中定义的成员变量，类型为std::mutex。std::unique_lock类对象在该作用域内定义，离开该作用域后，std::unique_lock类对象的析构函数会解锁，因此无需显示的解锁。

通过std::mutex实现资源的占用非常简单，但这里牵扯到一个效率的问题。比如write()函数用于模拟比较耗时的写文件的功能，加锁以后read()就无法占用文件资源，必须等待write()全部完成后才能使用文件资源。但实际的情况是，大多数时候不能让某个线程占用一个资源太多的时间。一个非常常见的需求是，在write()执行了一段时间，比如循环了5次，先解锁，让read()函数先读取已经写入的5个数字，读取完成后，write()继续写入剩余的5个数字，最后read()再读取后面写入的5个数字。

对于这样的需求，需要一个解锁和通知的功能。