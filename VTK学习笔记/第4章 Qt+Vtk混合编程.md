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

