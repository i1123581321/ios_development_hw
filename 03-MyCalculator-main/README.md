# 计算器应用

171860687

钱正轩

`171860687@smail.nju.edu.cn`

## mvc 架构

本次实验采用了 mvc 架构，由于计算器只有一个 main 界面，故没有在代码中显式实现 view，而是使用了 storyboard 当作 view，vc 位于 Controller 目录下，作用是处理 view 传来的事件，将其交给 model 处理后再使用结果来更改 view 的内容，这里 view 的事件直接通过 target-action 委托给 vc 处理，而 vc 通过 outlet 获得控件对象并更改其内容

model 实现了主要的业务逻辑，即计算。model 定义了一个 Calculator 类以及一些附属的结构，同时定义了一系列 enumeration 来代表按键或者说输入，同时定义了 Int 类型的 raw value，因为 view 传递来的 button 只能附带一个 tag，只要将对应 button 的 tag 设为对应枚举 case 的 raw value，vc 即可通过构造器获取枚举对象并传递给 model。model 接受一个输入按键，返回一个 Double 类型的数值，再由 vc 生成不同格式的字符串修改 view 中的控件，实现了 view 和 model 的完全解耦

## 计算功能的实现

model 中定义了 5 个枚举类型，其中四个分别代表四类按键

* 功能按键，如 AC，m 系列按键，等于
* 单目运算符
* 双目运算符
* 数字和小数点

单目和双目运算符分别有一个 `(Double)->Double` 和 `(Double, Double)->Double` 类型的 compute property，返回能实现计算功能的函数

另一个枚举类型的四个 case 代表四种按键，每个 case 有一个对应类型枚举的 associate value，这个枚举代表按键，用于 vc 向 model 传递输入，同理在 vc 中有四个函数分别处理和生成 4 个类型按键的枚举对象，view 中的控件通过 target-action 和这四个函数关联起来

model 有一个主寄存器，在接受到按键后，如果是数字或小数点，则将其放入 input buffer 拼接为字符串，然后用 Double 的构造器生成数值更新寄存器，如果是单目运算符，则直接调用其绑定的方法更新寄存器，如果是双目运算符，则将当前寄存器值和运算符压入栈，如果当前运算符优先级比栈顶的高则直接压入，否则弹出栈顶并调用栈顶运算符，栈顶寄存器值和当前寄存器值进行运算，然后再将当前运算符和结果入栈，再与新的栈顶比较，直至栈空或当前运算符优先级高于栈顶运算符，这样可以实现没有括号的情况下不同优先级双目运算按序输入后得到正确结果
