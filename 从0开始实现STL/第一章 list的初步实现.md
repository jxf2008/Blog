## 数组和链表的不足

在C和C++中，如果需要处理大量的同类型数据，首先会想到使用C和C++内置的数组，但内置的数组在使用时存在2个非常棘手的问题。第一，数组在定义时就需要确定大小，也就是数组包含元素的个数，一但定义就无法更改，而实际情况在需要更改元素个数的情况比比皆是，其次，大多数时候，需要在一组数据中插入，删除若干个元素，对于这样简单的操作，数组却无能为力，通常基于数组的解决方案是重新定义数组并复制，这种方法在很多时候会造成巨大的开销。

在C中，有很多处理上述情况的方案，其中一个广泛应用的使用链表，比如如果处理学生信息相关的数据时，可以使用一个双向链表，节点结构类似
```c++
struc Student{
    Student*  prev;
    char*     name;
    int       age;
    Student*  next;
};
```
然后提供一些列函数来处理链表的添，改，删等操作，一个双向链表可以很好的解决数据的删除，添加等操作，尤其双向链表在头部和尾部进行数据的添加和删除，执行时间是固定时间O(1),这使得双向链表称为这类情况的首选解决方案

但以C++的观观念来看这个问题，双向链表虽然比数组的功能更加强大，却有两个问题，首先，如果你经常实现双向链表这种数据结构，你会发现即使你小心翼翼，但任然有很多犯错的机会<sup>引1</sup>,其次，双向链表缺乏对泛型的支持，你为了处理学生信息花大力气实现了一个双向链表，但你又很快需要处理学生喜欢的全部电影的数据，于是你不得不立刻实现一个Film类的双向链表。。。。。

## 实现list

为此，针对上述两个问题，可以使用C++的方式，首先将链表封装为一个类MList(即My List,区别于标准库里的std::list),其次，使用模板类来实现MList,使得MList可以支持泛型。

对于MList，需要对双向链表做一个少许的改动，通常的双向链表设计，是将第一个节点的prev指针设为null,将最后一个节点的next设为null,这样就可以判断链表的Head和tail，确定了链表的head和tail,就可以很容易历遍整个链表，基本结构类似下图：

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/STL/LIST1.png)

而MList则需要做一些改进，将双向链表设计为环状的双向链表，具体做法是增加一个空的节点，该节点的value值为空值,prev指针指向链表的最后一个节点，next指针指向链表的第一个节点，同理，链表的第一个节点的prev和最后一个节点的next指针均指向该空节点。类似下图：

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/STL/LIST2.png)

这种设计一个主要好处就是只需要记录一个节点，也就是这个空值的节点，就可以历遍整个链表中所有节点。下面是初步实现

```c++
template<typename N>
struct Node {
	Node* prev;
	Node* next;
	N     value;
};
//用一个结构来储存数据，这是一个很常见的双向链表的节点

template<typename T>
class MList {
private:
	Node<T>* node;
public:
	MList();
	MList(const T& v, std::size_t n);
	explicit MList(std::size_t n);
	~MList();
	void push_back(const T& v);
	void push_fornt(const T& v);
	void remove(std::size_t n);
	T at(std::size_t n)const;
	std::size_t size() const;
	template<typename T1>
};

template<typename T>
MList<T>::MList() {
	node = static_cast<Node<T>*>(operator new(sizeof(Node<T>)));

	new(node) Node<T>();

	node->prev = node;
	node->next = node;
}
//默认构造函数，如果没有储存任何数据，则node的prev和next指针都指向自己，
//这样一个节点就可以闭环，这也是和双向链表最大的不同，任何时候都必须闭环

template<typename T>
MList<T>::MList(const T& v, std::size_t n) {
	Node<T>* node_head = static_cast<Node<T>*>(::operator new(sizeof(Node<T>)));
	node               = static_cast<Node<T>*>(operator new(sizeof(Node<T>)));

	new(node_head) Node<T>();
	new(node) Node<T>();


	Node<T>* item_tmp = node;
	for (std::size_t i = 0; i < n; ++i) {
		Node<T>* item = static_cast<Node<T>*>(::operator new(sizeof(Node<T>)));
		new(item) Node<T>();  //此处使用了T类的默认构造函数
		item->prev = item_tmp;
		item->value = v;     //此处使用了T类的复制构造函数
		item_tmp->next = item;
		item_tmp = item;
	}

	item_tmp->next = node;
	node->prev = item_tmp;
}

//由于Node类只有默认构造函数，因此该MList的构造函数需要多调用一次T类的复制构造函数

template<typename T>
MList<T>::MList(std::size_t n) {
	Node<T>* node_head = static_cast<Node<T>*>(::operator new(sizeof(Node<T>)));
	node               = static_cast<Node<T>*>(operator new(sizeof(Node<T>)));

	new(node_head) Node<T>();
	new(node) Node<T>();


	Node<T>* item_tmp = node;
	for (std::size_t i = 0; i < n; ++i) {
		Node<T>* item = static_cast<Node<T>*>(::operator new(sizeof(Node<T>)));
		new(item) Node<T>();
		item->prev = item_tmp;
		item_tmp->next = item;
		item_tmp = item;
	}

	item_tmp->next = node;
	node->prev = item_tmp;
}

template<typename T>
MList<T>::~MList() {
	Node<T>* item = node;
	while (item->next != node){
		item = item->next;
		item->prev->~Node<T>();
		::operator delete(item->prev);
	}
}

template<typename T>
void MList<T>::push_back(const T& v) {
	Node<T>* new_node = static_cast<Node<T>*>(::operator new(sizeof(Node<T>)));
	new (new_node) Node<T>;

	new_node->value = v;
	new_node->prev = node->prev;
	new_node->next = node;


	node->prev->next = new_node;
	node->prev = new_node;
}

template<typename T>
void MList<T>::push_fornt(const T& v) {
	Node<T>* new_node = static_cast<Node<T>*>(::operator new(sizeof(Node<T>)));
	new (new_node) Node<T>;

	new_node->value = v;
	new_node->prev = node;
	new_node->next = node->next;

	node->next->prev = new_node;
	node->next = new_node;
}
//以上2个函数实现了从链表头和尾添加元素的操作，函数执行时间是固定时间O(1)

template<typename T>
void MList<T>::remove(std::size_t n) {
	Node<T>* tmp_node = node->next;
	bool exist_item = true;
	for (std::size_t i = 0; i < n; ++i) {
		if (tmp_node->next == node) {
			exist_item = false;
			break;
		}
		tmp_node = tmp_node->next;
	}

	if (exist_item) {
		tmp_node->prev->next = tmp_node->next;
		tmp_node->next->prev = tmp_node->prev;
		tmp_node->~Node<T>();
		::operator delete(tmp_node);
	}
}
//删除指定索引的元素，由于采用双向链表作为底层实现，因此需要逐个历遍链表
//该函数的执行时间是线性时间O(n)

template<typename T>
T MList<T>::at(std::size_t n)const {
	std::size_t count = 0;
	Node<T>* tmp_node = node->next;
	while (tmp_node->next != node && n != count) {
		++count;
		tmp_node = tmp_node->next;
	}

	return n == count ? tmp_node->value : T();
}
//同样需要历遍链表中的元素，执行时间也是O(n)

template<typename T>
std::size_t MList<T>::size()const {
	if (node->next == node)
		return 0;

	std::size_t n = 1;
	Node<T>* tmp_node = node->next;
	while (tmp_node->next != node){
		++n;
		tmp_node = tmp_node->next;
	}
	return n;
}
```

