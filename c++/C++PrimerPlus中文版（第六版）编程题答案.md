系统ubuntukylin14.04 编译器g++4.8.2

1.所有程序均编译通过，运行良好

2.未在其他系统上测试，也未使用其他编译器测试

3.有生之年一定填完此坑！

## 第二章

[7-1](#7-1)    
[7-2](#7-2)  
[7-3](#7-3)  
[7-4](#7-4)  
[7-5](#7-5)      
[7-6](#7-6)  
[7-7](#7-7)  
[7-8](#7-8)  
[7-9](#7-9)      
[7-10](#7-10)  


## 第三章

## 第四章

## 第五章

## 第六章

## 第七章

## 第八章

## 第九章

## 第十章


<h2 id="7-1">7-1</h2>

```c++
#include <iostream>

double avg(double x , double y);

int main()
{
    using namespace std;
    int x = 0;
    int y = 0;
    while(1)
    {
        cout<<"请输入第一个数:";
        cin>>x;
        if(!cin)
            break;
        cout<<"请输入第二个数:";
        cin>>y;
        if(!cin)
            break;   //首先确保输入的是double
        if(x ==0 or y ==0)
            break;   //然后确保输入的2个数都不为0
        cout<<"调和平均数:"<<avg(x,y)<<endl;
    }
    cout<<"程序结束";
    return 0;
}
double avg(double x , double y)
{
    return (2*x*y)/(x+y);
}
```

<h2 id="7-2">7-2</h2>

```c++
#include<iostream>

int fillArray(double golf[] , int limit);
void showArray(const double golf[] , int limit);
void avgArray(const double golf[] , int limit);

const int MAX = 10;

using namespace std;

int main()
{
    int SIZE = 0;
    double golf[MAX];
    SIZE = fillArray(golf,MAX);
    showArray(golf,SIZE);
    avgArray(golf,SIZE);
    return 0;
}

int fillArray(double golf[] , int limit)
{
    double achievement = 0;
    int size = 0;
    golf[0] = 0;  //先把数组的第一个数填充位0，如果手动输入的时候第一个数字输入非法可以避免段错误
    for(int i = 0 ; i < limit ; ++i) 
    {
        cout<<"请输入第"<<i+1<<"个成绩";
        cin>>achievement;
        if(!cin)
        {
            cout<<"输入结束\n";
            break;
        }
    if(achievement < 0 or achievement > 100)  //不会高尔夫，假设高尔夫的成绩位0-100直接的double..
    {
        cout<<"输入结束\n";
        break;
    }
    golf[i] = achievement;
    ++size;
    }
    return size;
}

void showArray(const double golf[] , int limit)
{
    if(limit == 0)
        cout<<"无效的成绩.\n";
    for(int i = 0 ; i < limit ; ++i)
        cout<<"第"<<i+1<<"个高尔夫成绩为"<<golf[i]<<endl;
}

void avgArray(const double golf[] , int limit)
{
    double sue = 0;
    for(int i = 0 ; i < limit ; ++i)
    sue = sue + golf[i];
    if(limit != 0)
        sue = sue/limit;
    cout<<"高尔夫的平均成绩为"<<sue;
}
```
<h2 id="7-3">7-3</h2>

```c++
#include <iostream>

using namespace std;

struct box
{
    char maker[40];
    float height;
    float width;
    float lenght;
    float volume;
};

void showBox(box myBox);
void countVolume(box* myBox);

int main()
{
    box boxes = {"Volume",10.1,20.2,30.3,0};
    cout<<"立方体数据:\n";
    showBox(boxes);
    countVolume(&boxes);
    cout<<"立方体数据已经更改:\n";
    showBox(boxes);
    return 0;
}

void showBox(box myBox)
{
    cout<<"名称:"<<myBox.maker<<endl;
    cout<<"高度:"<<myBox.height<<endl;
    cout<<"宽度:"<<myBox.width<<endl;
    cout<<"长度:"<<myBox.lenght<<endl;
    cout<<"体积:"<<myBox.volume<<endl;
}

void countVolume(box* myBox)
{
    myBox->volume = (myBox->height) * (myBox->width) * (myBox->lenght);
}
```

<h2 id="7-4">7-4</h2>

```c++
#include <iostream>

long double probability(int all , int right);

int main()
{
    using namespace std;
    int nu = 0;
    int choose = 0;
    cout<<"请输入普选号码总数以及选择的号码个数.\n";
    cin>>nu>>choose;
    long double commonPro = probability(nu,choose);
    cout<<"请输入特选号码总数以及选择号码个数.\n";
    cin>>nu>>choose;
    long double specialPro = probability(nu,choose);
    cout<<"中奖概率位"<<commonPro*specialPro;
    return 0;
}

long double probability(int all , int right)  //计算概率
{
    long double pro = 1;
    for(int i = right ; i > 0 ; --i)
    {
        pro = pro * right / all;
        --right;
        --all;
    }
    return pro;
}
```

<h2 id="7-5">7-5</h2>

```c++
#include <iostream>

long long goRound(int nu);  //c++11 long long

int main()
{
    using namespace std;
    int ts = 0;
    cout<<"请输入一个整数:";
    while(cin>>ts)
    {
        if(ts < 0 or ts > 12)  //乘积计算限定在0-12否则long long也可能吃不消。。
            break;
        cout<<ts<<"的乘积为:"<<goRound(ts)<<endl;
    }
    cout<<"Bye!";//当输入不为整数的时候推出循环
    return 0;
}
   
long long goRound(int nu)
{
    long long result = nu;
    if(nu == 0)
    return 1;
    else 
    {
        --nu;
        result = result * goRound(nu);
   }
   return result;
}
```

<h2 id="7-6">7-6</h2>

```c++
#include <iostream>

int fillArray(double* arr , int lenght);  
void showArray(const double* arr , int lenght);
void turnArray(double* arr , int lenght);

using namespace std;

int main()
{
    double myArray[10];  //先声明一个包含10个元素的数组
    int maxLenght = fillArray(myArray,10);
    showArray(myArray,maxLenght);
    cout<<"反转数组.\n";
    turnArray(myArray,maxLenght);
    showArray(myArray,maxLenght);
    cout<<"除首尾元素外，反转其他元素.\n";
    double* newHeader = myArray+1;
    int newTail = maxLenght - 2;
    turnArray(newHeader,newTail);  //这里传入数组第二个元素的地址，长度为原数组元素个数-2
    showArray(myArray,maxLenght);
    return 0;
}

int fillArray(double* arr , int lenght)
{
    double mid = 0;
    int realLenght = 0;
    for(int i = 0 ; i < lenght ; ++i)
    {
        cout<<"请输入第"<<i+1<<"个数:";
        if(cin>>mid)
        {
            *(arr+i) = mid;
            ++realLenght;
        }
        else 
            break;
    }
    return realLenght;
}

void showArray(const double* arr , int lenght)
{
    for(int i = 0 ; i < lenght ; ++i) 
        cout<<"第"<<i+1<<"个数为"<<*(arr+i)<<endl;
}

void turnArray(double* arr , int lenght)
{
    double midArray[lenght];  //声明一个数组暂时存放数据
    for(int i = 0 ; i < lenght ; ++i)
        *(midArray+i) = *(arr+i);
    for(int i = 0 ; i < lenght ; ++i)
        *(arr+i) = *(midArray + (lenght-1) - i);  //翻转
}
```
<h2 id="7-7">7-7</h2>

```c++
#include <iostream>

const int MAX = 5;
using namespace std;

const double* fill_array(double ar[] , int limit);  //填充数组函数
void show_array(const double ar[] , const double* last);  //显示数组
void change_array(int r , double ar[] , const double* last);

int main()
{
    double oldHouse[MAX];
    const double* lastHouse = fill_array(oldHouse,MAX);  //填充
    show_array(oldHouse,lastHouse);  //第一次显示
    change_array(3,oldHouse,lastHouse);  //因子随便选了个数字3，只是为了说明程序功能
    show_array(oldHouse,lastHouse);  //显示X因子后的数组
    return 0;
}

const double* fill_array(double ar[] , int limit)
{
    double num = 0;
    int size = 0;
    for(int i = 0 ; i < limit ; ++i)
    {
        cout<<"请输入第"<<i+1<<"个数.";
        cin>>num;
        if(!cin)            //判断输入是否位double,如果输入非法结束
        {
            cin.clear();
            while(cin.get() != '\n')
                continue;
            cout<<"输入非法数据，填充结束\n";
            ar[size] = 0;  //这两行作用：第一个输入为非法，则该数组默认第一个数值位0，避免段错误，下同
            ++size;        //这两行如果注释掉，那第一个输入错误或为负，程序就会出错
            break; 
        }
        else if(num < 0)    //输入负数，控制结束
        {
            cout<<"数组填充完成.\n";
            ar[size] = 0;  //同上
            ++size;
            break;
        }
        ar[size] = num;
        ++size;
    }
    return &(ar[size-1]);
}

void show_array(const double ar[] , const double* last)
{
    cout<<"显示数组\n";
    const double* mid = ar;
    for(int i = 0 ;  ; ++i)  //省略掉判断条件，作为无限循环
    {
        cout<<"第"<<i+1<<"个数为"<<ar[i]<<endl;
        if((mid+i) == last)
            break;
    }
}

void change_array(int r , double ar[] , const double* last)
{
    for(int i = 0 ; ; ++i)
    {
        ar[i] *= r;
        if(ar+i == last)
            break;
    }
}
```
<h2 id="7-8">7-8</h2>

```c++
#include <iostream>

using namespace std;

const int season = 4;
const char* seasonName[season] = {"Sprint","Summer","Fall","Winner"};  //c++11
void fillArray(double* arr , int season);
void showArray(const double* arr , int season); 

int main()
{
    double InSeason[season];
    fillArray(InSeason,season);
    showArray(InSeason,season);
    return 0;
}

void fillArray(double* arr , int season)
{
    for(int i = 0 ; i < season ; ++i)
    { 
        cout<<"请输入"<<*(seasonName+i)<<"的收入.";
        cin>>*(arr+i);
    }
}

void showArray(const double* arr , int season)
{
    double cost = 0;
    for(int i = 0 ; i < season ; ++i)
    {
        cout<<*(seasonName+i)<<"收入为"<<*(arr+i)<<"\n";
        cost += *(arr+i);
    }
    cout<<"总收入:"<<cost;
}


//第二小题
#include<iostream>

using namespace std;

const int season = 4;
const char* seasonName[season] = {"Sprint","Summer","Fall","Winner"};

struct inCome
{
    double takeIn[season];
};

void fillArray(inCome* re);
void showArray(const inCome* re);

int main()
{
    inCome gets;
    fillArray(&gets);
    showArray(&gets);
    return 0;
}

void fillArray(inCome* re)
{
    for(int i = 0 ; i < season ; ++i)
    {
        cout<<"请输入"<<*(seasonName+i)<<"的收入:";
        cin>>re->takeIn[i];
    }
}

void showArray(const inCome* re)
{
    double cost = 0;
    for(int i = 0 ; i < season ; ++i)
    {
        cout<<*(seasonName+i)<<"的收入为"<<re->takeIn[i]<<endl;
        cost += re->takeIn[i];
    }
    cout<<"总收入为"<<cost;
}

```
<h2 id="7-9">7-9</h2>

```c++
#include <iostream>

using namespace std;
const int maxLen = 30;

struct student
{
    char fullName[maxLen];
    char hobby[maxLen];
    int oopLevel;
};

int getInfo(student* pa , int lenght);
void display_1(student someone);
void display_2(const student* someone);
void display_3(const student* allStudent , int nu);

int main()
{
    int sizeOfClass = 0;
    cout<<"请输入学生人数:";
    cin>>sizeOfClass;
    student* myClass = new student[sizeOfClass];
    int nus = getInfo(myClass,sizeOfClass);
    for(int i = 0 ; i < nus ; ++i)
    {
        cout<<"第"<<i+1<<"个学生信息."<<endl;
        display_1(*(myClass+i));
        display_2(myClass+i);
    }
    display_3(myClass,nus);
    delete [] myClass;
    return 0;
}

int getInfo(student* pa , int lenght)
{
    int realSize = 0;
    char goEnd = 'q';
    cout<<"学生信息录入，输入 'q' 退出输入.\n";
    for(int i = 0 ; i < lenght ; ++i)
    {
        cin.get();
        cout<<"请输入第"<<i+1<<"个学生的姓名";
        cin.getline((pa+i)->fullName,maxLen);
        if(*((pa+i)->fullName) == goEnd)   //是否结束输入
            break;

        cout<<"请输入第"<<i+1<<"个学生的爱好.";
        cin.getline((pa+i)->hobby,maxLen);
        if(*((pa+i)->hobby) == goEnd)
            break;

        cout<<"请输入第"<<i+1<<"个学生的成绩.";
        if(!(cin >> ((pa+i)->oopLevel)))
            break;                //输入不为整数也被认为结束输入

        if((pa+i)->oopLevel < 0)
        break;  //输入的成绩小于0，结束输入
    
        ++realSize;
    }
    return realSize;
}

void display_1(student someone)
{
    cout<<"姓名:"<<someone.fullName<<endl;
    cout<<"爱好:"<<someone.hobby<<endl;
    cout<<"成绩:"<<someone.oopLevel<<endl;
}

void display_2(const student* someone)
{
    cout<<"姓名:"<<someone->fullName<<endl;
    cout<<"爱好:"<<someone->hobby<<endl;
    cout<<"成绩:"<<someone->oopLevel<<endl;
}

void display_3(const student* allStudent , int nu)
{
    for(int i = 0 ; i < nu ; ++i)
    {
        cout<<"第"<<i+1<<"名学生信息."<<endl;
        cout<<"姓名:"<<(allStudent+i)->fullName<<endl;
        cout<<"爱好:"<<(allStudent+i)->hobby<<endl;
        cout<<"成绩:"<<(allStudent+i)->oopLevel<<endl;
    }
}
```

<h2 id="7-10">7-10</h2>

```c++
#include <iostream>

double add(double x , double y);  //求和
double qtc(double x, double y);  //求乘积
double calculate(double x , double y , double (*pt)(double , double ));

int main()
{
    using namespace std;
    double X = 0;
    double Y = 0;
    cout<<"请输入2个数字";
    while(cin>>X and cin>>Y)
    {
        cout<<"两数之和为"<<calculate(X,Y,add)<<endl;
        cout<<"两数乘积为"<<calculate(X,Y,qtc)<<endl;
        cout<<"请输入2个数字";
    }
    cout<<"Bye!";
    return 0;
}

double add(double x , double y)
{
    return x+y;
}

double qtc(double x , double y)
{
    return x*y;
}

double calculate(double x , double y , double (*pt)(double , double ))
{
    return (*pt)(x,y);
}
```