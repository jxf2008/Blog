本章内容假设你已经非常熟悉Qt的编程，如果未说明，则Qt的版本是6.5.2。另外如果运行本章示例，请确定VTK编译了Qt相关模块，因为VTK很多版本默认是不编译Qt相关模块的，编译相关请参见[VS2022+VTK9.4.1安装](https://github.com/jxf2008/Blog/blob/master/VTK%E5%AD%A6%E4%B9%A0%E7%AC%94%E8%AE%B0/%E7%AC%AC0%E7%AB%A0%20VS2022%2BVTK9.4.1%E5%AE%89%E8%A3%85.md)

Qt是一个非常成熟的跨平台GUI框架，在使用VTK的时候，大部分时间是在某个GUI程序中调用VTK；虽然VTK也提供了一些GUI相关的类，但这些类的功能往往只是最基本的功能，因此在在实际项目中，往往是使用Qt来构建GUI界面，而VTK实现模型渲染，因此Qt+VTK混合编程就显得非常必要

## 在Qt中使用vtk

首先利用VS2022创建一个标准的Qt项目，其中模块需要除了基本的core,widgets和gui外，还需要添加opengl和openglwidget这两个模块。

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/VTK4-1.png)

然后将vtk的头文件目录，库目录和库名称添加进这个工程，这样就可以在Qt工程中使用VTK了

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/VTK4-2.png)

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/VTK4-3.png)

VTK提供了QVTKOpenGLNativeWidget类来实现VTK在Qt中的使用，该类继承自Qt的QOpenGlWidget类，这里演示一个最基本的Qt程序，即通过QVTKOpenGLNativeWidget来实现在Qt程序中显示VTK模型

首先是头文件
```c++
#ifndef VTKSHOWWIDGET_H__
#define VTKSHOWWIDGET_H__

#include <QPushButton>
#include <QVTKOpenGLNativeWidget.h>

class VtkShowWidget : public QWidget{
	Q_OBJECT
private:
	QPushButton* pushbutton_close;
	QPushButton* pushbutton_show;
	QVTKOpenGLNativeWidget* widget_vtk;
public:
	VtkShowWidget(QWidget* parent = nullptr);
private slots:
	void show_vtk_arrow();
};

#endif
```
头文件中使用了QVTKOpenGLNativeWidget来显示VTK模型，而两个QPushButton分别用于点击显示模型和关闭程序；这里定义了私有槽，用于显示VTK模型

```c++
#include <QVBoxLayout>
#include <QHBoxLayout>

#include <vtkActor.h>
#include <vtkArrowSource.h>
#include <vtkNamedColors.h>
#include <vtkNew.h>
#include <vtkPolyDataMapper.h>
#include <vtkRenderWindow.h>
#include <vtkRenderWindowInteractor.h>
#include <vtkRenderer.h>
#include <vtkGenericOpenGLRenderWindow.h>
#include "VtkShowWidget.h"

VtkShowWidget::VtkShowWidget(QWidget* parent) :QWidget(parent) {
	pushbutton_show = new QPushButton(tr("Show"));
	pushbutton_close = new QPushButton(tr("Close"));
	widget_vtk = new QVTKOpenGLNativeWidget();

	QHBoxLayout* layout_button = new QHBoxLayout();
	layout_button->addWidget(pushbutton_show);
	layout_button->addWidget(pushbutton_close);
	QVBoxLayout* layout_main = new QVBoxLayout();
	layout_main->addWidget(widget_vtk);
	layout_main->addLayout(layout_button);
	setLayout(layout_main);
	setFixedSize(400, 300);

	connect(pushbutton_show, SIGNAL(clicked()), this, SLOT(show_vtk_arrow()));
	connect(pushbutton_close, SIGNAL(clicked()), this, SLOT(close()));
}

void VtkShowWidget::show_vtk_arrow() {
	vtkNew<vtkNamedColors> colors;

	vtkNew<vtkArrowSource> arrowSource;
	arrowSource->Update();

	vtkNew<vtkPolyDataMapper> mapper;
	mapper->SetInputConnection(arrowSource->GetOutputPort());
	vtkNew<vtkActor> actor;
	actor->SetMapper(mapper);

	vtkNew<vtkRenderer> renderer;

    //不能使用vtkRenderWindow
	vtkNew<vtkGenericOpenGLRenderWindow> renderWindow; 
	renderWindow->SetWindowName("Arrow");
	renderWindow->AddRenderer(renderer);

    //这里使用vtkGenericOpenGLRenderWindow来代替vtkRenderWindowInteractor
	widget_vtk->setRenderWindow(renderWindow);

	renderer->AddActor(actor);
	renderer->SetBackground(colors->GetColor3d("MidnightBlue").GetData());

	renderWindow->SetWindowName("Arrow");
	renderWindow->Render();
}

```
在show_vtk_arrow()槽中，和之前的显示模型的代码有2处不同，第一个使用了vtkGenericOpenGLRenderWindow来代替之前的vtkRenderWindow，该类是用于和QVTKOpenGLNativeWidget一起显示，如果任然使用之前的vtkRenderWindow，则会编译报错
```shell
QVTKOpenGLNativeWidget requires a `vtkGenericOpenGLRenderWindow`. ` vtkWin32OpenGLRenderWindow ` is not supported.
```

第二个不同便是使用vtkGenericOpenGLRenderWindow来代替了vtkRenderWindowInteractor，因为vtkGenericOpenGLRenderWindow继承自QOpenglWidget类，可以在Qt中无缝使用

```c++
//main.cpp
#include <QApplication>
#include "VtkShowWidget.h"

int main(int argc, char** argv) {
	QApplication app(argc, argv);
	VtkShowWidget vtkWidget{};
	vtkWidget.show();
	return app.exec();
}
```
运行后，点击"Show"变可以显示VTK模型

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/VTK4-4.gif)


## 在Qt中使用vtk事件

在很多项目中，经常需要用到vtk的各种事件，而这在Qt项目中，如果需要使用这些vtk的事件，一种方法是使用之前的vtkCommand，另一种方法是将vtk的事件和Qt的信号与槽机制一起使用，即将vtk的事件和Qt的槽绑定起来，当VTK的事件触发时，调用Qt的槽。

接下来这个示例同时使用了上述两种方法，可以看下这两种方法的不同以及适用的场景。在这个示例中，一个窗体内包含了两个模型，当用户选择（鼠标左键点击）了其中一个模型，该模型的背景颜色会发生改变

![](https://jxf2008-1302581379.cos.ap-nanjing.myqcloud.com/github_blog/VTK4-6.gif)

首先，第一步需要做的是确定用户究竟点击了哪个模型，因此需要设计一个vtkCommand来实现判断
```c++
//ClickModelCMD.h

#include <vtkCommand.h>
class ClickModelCMD : public vtkCommand{
private:
    //一个窗口内有多个Render，记录用户点击了哪一个
	vtkRenderer* currentRender;
public:
	explicit ClickModelCMD();
	~ClickModelCMD() = default;
	virtual void Execute(vtkObject* caller, unsigned long eventId, void* vtkNotUsed(callData))override;
	static ClickModelCMD* New() { return new ClickModelCMD(); }
	void set_current_render(vtkRenderer* render) { currentRender = render; }
	vtkRenderer* get_current_renderer()const { return currentRender; }
};
```
然后是实现
```c++
//ClickModelCMD.cpp
#include <vtkRenderWindowInteractor.h>
#include <vtkGenericOpenGLRenderWindow.h>
#include <vtkPropPicker.h>
#include <vtkRendererCollection.h>
#include "ClickModelCMD.h"

ClickModelCMD::ClickModelCMD(): currentRender(nullptr){

}

void ClickModelCMD::Execute(vtkObject* caller, unsigned long eventId, void* vtkNotUsed(callData)) {
	if (eventId == vtkCommand::LeftButtonPressEvent) {
		//通过GetEventPosition()函数来获得用户点击的坐标
		vtkRenderWindowInteractor* winInteractor = static_cast<vtkRenderWindowInteractor*>(caller);
		int* clickPoint = winInteractor->GetEventPosition();
		vtkNew<vtkPropPicker> picker;

		vtkGenericOpenGLRenderWindow* renderWindow = static_cast<vtkGenericOpenGLRenderWindow*>(winInteractor->GetRenderWindow());
		vtkRendererCollection* allRender = renderWindow->GetRenderers();
		allRender->InitTraversal();
		currentRender = allRender->GetNextItem();
		while (currentRender != nullptr) {
			if (picker->Pick(*clickPoint, *(clickPoint + 1), 0, currentRender))
				break;
			currentRender = allRender->GetNextItem();
		}
	}
}
```
这里出现了两个新的类，vtkPropPicker类用于检索点击和Render是否匹配，该类的成员函数Pick()，前三个参数是对应的三维坐标，而第四个参数则是判断的Render，如果该三维坐标位于Render内，则Pick()返回值为0，否则返回1，在本例中由于只考虑点击的范围，因此三维坐标的第三个值直接写为0

另一个新的类是vtkRendererCollection，这个类可以看出一个存放了多个vtkRenderer的链表，其中GetNextItem()函数用户返回下一个对象，如果已经位于最后一个对象，则再次调用该函数时，返回值为nullptr；而InitTraversal()用于初始化其内部的指针，在调用InitTraversal()后，再调用GetNextItem()可以确保其返回指向第一个对象的指针。

在这个ClickModelCMD类的Execute()函数中，首先获得用户鼠标左键点击时的坐标，然后历遍全部的vtkRenderer，最后通过vtkPropPicker类的Pick()函数判断用户纠结点击了哪一个vtkRenderer

接下来是主窗体的实现
```c++
#include <QPushButton>
#include <QDialog>
#include <QVTKOpenGLNativeWidget.h>
#include <vtkEventQtSlotConnect.h>

#include "ClickModelCMD.h"

class ClickModelCMD;

class QColorSetDialog : public QDialog{
	Q_OBJECT
private:
	QVTKOpenGLNativeWidget* widget_vtk;
	QPushButton* pushbutton_close;
	void creat_vtk_model();
    //vtkEventQtSlotConnect类必须放在vtkSmartPointer内
	vtkSmartPointer<vtkEventQtSlotConnect> slotConnections;
	ClickModelCMD* vtkcmd_click;
public:
	QColorSetDialog(QWidget* parent = nullptr);
private slots:
	void left_click();
};
```
在头文件中，出现了vtkEventQtSlotConnect类，该类专门用户将vtk的事件和Qt的槽连接，该类需要放在vtkSmartPointer中，因为Qt使用自带的内存管理系统，并不会管理VTK相关的类，而如果程序退出时，vtkEventQtSlotConnect没有显示的断开和Qt的槽的连接，会导致内存泄漏。因此将vtkEventQtSlotConnect放入vtkSmartPointer中，这样在程序结束时，tkEventQtSlotConnect对象在析构前会自动断开和Qt的槽的连接，这样可以避免内存泄漏。

在类定义中，定义了一个left_click()槽函数，该槽函数用于和VTK的事件链接，和Qt的普通槽函数相比，和VTK事件连接的槽函数有些特殊，其参数是固定的，只有下列几种形式

1. MySlot()；
2. MySlot(vtkObject* caller)；
3. MySlot(vtkObject* caller, unsigned long )；
4. MySlot(vtkObject* caller, unsigned long vtk_event, void* client_data)；
5. MySlot(vtkObject* caller, unsigned long vtk_event, void* client_data, void* call_data)；
6. MySlot(vtkObject* caller, unsigned long vtk_event, void* client_data, void* call_data, vtkCommand*)；

接下来是QColorSetDialog类的实现
```c++
#include <QHBoxLayout>
#include <QVBoxLayout>
#include <QColorDialog>
#include "QColorSetDialog.h"

#include <vtkActor.h>
#include <vtkCamera.h>
#include <vtkCylinderSource.h>
#include <vtkNamedColors.h>
#include <vtkNew.h>
#include <vtkPolyDataMapper.h>
#include <vtkProperty.h>
#include <vtkGenericOpenGLRenderWindow.h>
#include <vtkRenderer.h>
#include <vtkSphereSource.h>
#include <vtkRendererCollection.h>

//选择和未选择的背景颜色
const std::array<double, 3> bkg_select({ 0.8,0.5,0.1 });
const std::array<double, 3> bkg_unselect({ 0.1,0.5,0.8 });

QColorSetDialog::QColorSetDialog(QWidget* parent):QDialog(parent){
	widget_vtk = new QVTKOpenGLNativeWidget();
	pushbutton_close = new QPushButton(tr("Close"));

	QHBoxLayout* layout_btn = new QHBoxLayout;
	layout_btn->addStretch();
	layout_btn->addWidget(pushbutton_close);
	QVBoxLayout* layout_main = new QVBoxLayout;
	layout_main->addWidget(widget_vtk);
	layout_main->addLayout(layout_btn);
	setLayout(layout_main);
	setFixedSize(600, 300);

	connect(pushbutton_close, SIGNAL(clicked()), this, SLOT(close()));

	creat_vtk_model();
	slotConnections = vtkEventQtSlotConnect::New();
	slotConnections->Connect(widget_vtk->renderWindow()->GetInteractor(), vtkCommand::LeftButtonPressEvent, this, SLOT(left_click()));
}

void QColorSetDialog::left_click() {
	vtkNew<vtkNamedColors> colors;
	vtkGenericOpenGLRenderWindow* renderWindow = static_cast<vtkGenericOpenGLRenderWindow*>(widget_vtk->renderWindow());
	vtkRendererCollection* allRender = renderWindow->GetRenderers();
	allRender->InitTraversal();
	vtkRenderer* renderTmp = allRender->GetNextItem();
	//用户鼠标左键点击后，将全部的vtkRenderer和ClickModelCMD内的当前vtkRenderer做比较
	//如果是是当前vtkRenderer设置一种背景色
	//如果不是，则设置另一种背景色
	while (renderTmp != nullptr) {
		if (renderTmp == vtkcmd_click->get_current_renderer()) 
			renderTmp->SetBackground(bkg_select.data());
		else 
			renderTmp->SetBackground(bkg_unselect.data());

		renderTmp->Render();
		renderTmp = allRender->GetNextItem();
	}
}
```
vtkEventQtSlotConnect的Connect()函数用于连接VTK的事件和Qt的槽，该函数的原型是
```c++
virtual void vtkEventQtSlotConnect::Connect	(
vtkObject *         vtk_obj,
unsigned long 	    event,
const QObject * 	qt_obj,
const char * 	    slot,
void * 	            client_data = nullptr,
float 	            priority = 0.0,
Qt::ConnectionType 	type = Qt::AutoConnection 
);	
```
其中client_data通常用于回调给客户端的函数，而priority表示该槽执行的优先级，数值越小，优先级越高

最后是生成模型的私有函数creat_vtk_model();的实现
```c++
void QColorSetDialog::creat_vtk_model() {
	vtkNew<vtkNamedColors> cylinderolors;

	//生成圆柱体

	vtkNew<vtkCylinderSource> cylinder;
	cylinder->SetResolution(8);

	vtkNew<vtkPolyDataMapper> cylinderMapper;
	cylinderMapper->SetInputConnection(cylinder->GetOutputPort());

	vtkNew<vtkActor> cylinderActor;
	cylinderActor->SetMapper(cylinderMapper);
	cylinderActor->GetProperty()->SetColor(cylinderolors->GetColor4d("Tomato").GetData());
	cylinderActor->RotateX(30.0);
	cylinderActor->RotateY(-45.0);

	vtkNew<vtkRenderer> cylinderrenderer;
	cylinderrenderer->AddActor(cylinderActor);
	cylinderrenderer->SetBackground(bkg_select.data());
	cylinderrenderer->ResetCamera();
	cylinderrenderer->GetActiveCamera()->Zoom(1.5);

	//生成球体
	vtkNew<vtkNamedColors> sphereColors;

	vtkNew<vtkSphereSource> sphereSource;
	sphereSource->SetCenter(0.0, 0.0, 0.0);
	sphereSource->SetRadius(5.0);
	sphereSource->SetPhiResolution(50);
	sphereSource->SetThetaResolution(50);
	sphereSource->LatLongTessellationOff();

	vtkNew<vtkPolyDataMapper> sphereMapper;
	sphereMapper->SetInputConnection(sphereSource->GetOutputPort());

	vtkNew<vtkProperty> actorProp;
	actorProp->SetColor(sphereColors->GetColor3d("Peru").GetData());
	actorProp->SetEdgeColor(sphereColors->GetColor3d("DarkSlateBlue").GetData());

	vtkNew<vtkActor> sphereActor;
	sphereActor->SetProperty(actorProp);
	sphereActor->SetMapper(sphereMapper);

	vtkNew<vtkRenderer> sphereRenderer;
	sphereRenderer->AddActor(sphereActor);
	sphereRenderer->SetBackground(bkg_unselect.data());

	//将2个模型同时添加进窗口
	cylinderrenderer->SetViewport(0.0, 0.0, 0.5, 1.0);
	sphereRenderer->SetViewport(0.5, 0.0, 1.0, 1.0);
	vtkNew<vtkGenericOpenGLRenderWindow> renderWindow;
	renderWindow->AddRenderer(cylinderrenderer);
	renderWindow->AddRenderer(sphereRenderer);

	widget_vtk->setRenderWindow(renderWindow);

	vtkcmd_click = ClickModelCMD::New();
	//程序第一次启动后，没有点击的情况下，默认左边的模型是被选中的模型
	vtkcmd_click->set_current_render(cylinderrenderer);
	widget_vtk->renderWindow()->GetInteractor()->AddObserver(vtkCommand::LeftButtonPressEvent, vtkcmd_click);
}
```
```c++
//main.cpp
#include <QApplication>
#include "QColorSetDialog.h"

int main(int argc, char** argv) {
	QApplication app(argc, argv);
	QColorSetDialog colorSetDialog{};
	colorSetDialog.show();
	return app.exec();
}
```