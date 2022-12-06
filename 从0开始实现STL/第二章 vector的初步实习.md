## list的不足

前一章的MList仅仅实现了用于说明问题的几个成员函数，以及list的基本结构。从实现上来看，list由于底层采用双向链表，因此在头尾添加/删除元素非常快速，但随机访问是list的弱项，如果数据需要大量的随机访问，使用list就明显不合适了。

## vector的优势

对于随机访问，自然想到的是数组，对于一个数组来说，访问第n个元素是固定时间，既
```c++
int* ptr = new int[m];
int v1 = *(ptr+1);  //语句1
int v2 = *(ptr+n);  //语句2
```
上述代码中语句1和语句2，无论m和n的值是多少，其执行时间是相同的,由此可见，对于需要随机访问情况，数组是个非常优先的数据结构。所以可以通过封装了数组vector类来解决随机访问的问题。但第一章也提过，数组在申请内存的时候就已经确定大小了，而实际编程中添加删除元素的情况比比皆是，数组删除尾部的元素成本较低，但如果要在尾部添加一个元素，成本就比较大了，因为每次需要添加元素的时候，都重新申请可以存放n+1(n为原数组的元素个数)类对象的内存，然后将原有的数据复制过去。一种成本较低的解决方案就是估算一下用户可能需要存放的元素个数为N，然后向系统申请可以存放(N * m)个对象的内存，这种设计的好处是可以在尾部预留一部分空间，如果用户尾部添加元素不多的话，就可以避免大量的数据复制工作，只有用户添加超过(N-1)*m个元素，才会出现大量的数据复制，而m的值可以设计人员设置，用户也可以根据自己的实际情况修改后在编译。

## vector的初步实现

```c++
#define MUILTIPLE 2
//这个宏就是上文中m的值，设计上vector会向系统申请存放已有数据2倍的内存
//用户也可以根据实际情况修改该值从而改变vector的内存申请

template<typename T>
class MVector {
private:
	T* first_item;
	T* last_item;
	T* end_item;
    //由于申请的内存是申请时数据元素的2倍，因此需要3个指针来定位
    //first_item定位第一个元素
    //last_item是随后一个元素
    //end_item是申请内存的最后一块

	void expand_alloc(std::size_t n);
public:
	MVector();
	MVector(const T& v, std::size_t n);
	~MVector();
	void push_back(const T& v);
	void push_fornt(const T& v);
	void remove(std::size_t n);
	T at(std::size_t n)const;
	std::size_t size() {return (last_item - first_item) / sizeof(T) + 1}const;
};

template<typename T>
MVector<T>::MVector() {
	expand_alloc(2)
}

template<typename T>
MVector<T>::MVector(const T& v, std::size_t n) {
	expand_alloc(n);

	T* tmp_ptr = first_item;
	while (first_item != last_item) {
		new (tmp_ptr) T(v);
		tmp_ptr += 1;
	}
}

template<typename T>
MVector<T>::~MVector() {
	T* tmp_ptr = first_item;
	while (first_item != last_item) {
		tmp_ptr->~T();
		tmp_ptr += 1;
	}
	::operator delete(first_item)
}

template<typename T>
void MVector<T>::expand_alloc(std::size_t n) {
	if (n < 1)
		return;
	first_item = static_cast<T*>(::operator new(sizeof(T) * n * MUILTIPLE + 1));
	last_item = first_item + n - 1;
	end_item = first_item + n * MUILTIPLE;
}
//这个私有函数用于申请内存，这里可以看出vector向系统申请2n+1的内存

template<typename T>
void MVector<T>::push_back(const T& v) {
	if (last_item + 1 = end_item) {
		T* first_tmp = first_item;
		T* last_tmp = last_item;
		T* end_tmp = end_item;

		expand_alloc(((first_tmp - last_tmp) / sizeof(T) +1) * 2);
		T* ptr = first_tmp;
		for (std::size_t i = 0; ; ++i) {
			if (first_tmp == last_tmp)
				break;
			*(first_item + i) = *(first_tmp + i);
			(first_tmp + i)->~T();
		}

		::operator delete(first_tmp);
	}

	T* tmp = last_item;
	last_item += 1;
	*tmp = v;
}
//在尾部添加一个元素，该函数如果判断已有内存以及不够用时，需要重新申请内存并复制数据
//这个函数也是使用vector一个不要注意的地方，在初始化vector的时候就需要考虑以后添加
//元素的数量

template<typename T>
void MVector<T>::push_fornt(const T& v) {
	T* first_tmp = first_item;
	T* last_tmp = last_item;
	T* end_tmp = end_item;

	if (last_item + 1 = end_item) 
		expand_alloc(((first_tmp - last_tmp) / sizeof(T) + 1) * 2);
	

	T* ptr = first_tmp;
	for (std::size_t i = 0; ; ++i) {
		if (first_tmp == last_tmp)
			break;
		*(first_item + i + 1) = *(first_tmp + i);
		(first_tmp + i)->~T();
	}

	::operator delete(first_tmp);

	*(first_item) = v;
}
//这个函数用于在vector前部添加元素，由于数组不支持在第一个元素前面的操作
//因此该函数的执行效率是灾难性的，每次添加都需要复制数据，执行时间为Θ(n)
//使用vector时应该避免调用该函数，如必须在头部操作数据，清考虑换用list

template<typename T>
void MVector<T>::remove(std::size_t n) {
	std::size_t lenght = size();
	if (n < 0 || n >= lenght)
		return;

	std::size_t len = lenght - n + 1;
	for (std::size_t i = 0; i < len ; ++n) {
		(first_item + n + i)->~T();
		*(first_item + i) = *(first_item + i + 1);
	}

	last_item->~T();
	last_item = first_item + n + len;
}
//remove函数的效率同样不高，为O(n),但函数调用n的值越靠近尾部，该函数执行的速度就越快
//因为n值越大，需要复制的元素就越少，而如果需要删除最后一个元素，就可以不用复制数据
//由此可以判断vector的pop_back()函数执行速度也是O(1)，虽然这里我没有实现该函数

template<typename T>
T MVector<T>::at(std::size_t n)const {
	std::size_t lenght = size();
	if (n < 0 || n >= lenght)
		return T();

	return *(first_item + n);
}
//这个函数是vector的最大优势，高速的随机访问，从这个函数可以看出访问vector内的任意一个元素，时间都是O(1);

```