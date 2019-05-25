# 代码生成器 For 蓝湖

## 展示图

![image-20190526032756135](http://ww2.sinaimg.cn/large/006tNc79ly1g3e69bxsulj31ap0sk0ys.jpg)

![image-20190526032906372](http://ww1.sinaimg.cn/large/006tNc79ly1g3e6ah7f8lj319h0rcjyr.jpg)

![image-20190526032936419](http://ww2.sinaimg.cn/large/006tNc79ly1g3e6azmvdoj30qn0hr77r.jpg)

## 功能介绍

- 自动识别 `View` `Label` `ImageView` 对于`Button`需要两步骤
- 支持自定义每种类型`Mustache`语言模板
- 支持自定义变量前缀

## 怎么使用

- 打开软件登录蓝湖的账号
- 打开页面找到元素
- 配置类型模板生成代码
- 复制粘贴

## Mustache输出的内容

```shell
{
"type" //类型 0为label 1为button 2为view 3为imageView
"textColor" //文本颜色 十六进制
"font" //字体大小
"text" //文本
"fontBlod" //字体类型
"boardWidth" //试图边框宽度
"boardColor" //边框颜色 十六进制
"backgroundColor" // 背景颜色
"cornerRadio" // 圆角
"isBold" // 字体是否加粗
"prefix" // 文件名称默认前缀
}
```

## 未来

- 自动复制内容
- 支持模板插件化
- 支持生成自动布局代码
