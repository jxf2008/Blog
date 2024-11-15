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
