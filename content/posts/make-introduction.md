---
title: "Introduction to Make"
date: 2020-05-03T08:42:08-07:00
draft: false
tags: ["make", "c", "build", "introduction"]
featured: true
description: "Make is one of the older tools that is still around. It is used with projects written in C, C++, Java, go and many other languages. Learn the basic of make and Makefiles."
---

Make is a build automation tool which generates executable from source code. It is really powerful, and dramatically simplifies lives of developers who have to work with compiled languages. Make defines a language that describes relationships between source code, intermediate files, and generated executable. This rules are defined in a special file, called Makefile. Although Make can quickly get complicated, you don't need to know everything to use it in your projects! 

First thing you need to know, any Makefile is just a set of rules structured. Each rule consists of the target, its prerequisites, and command to perform. It is structured the following way:

```makefile
target: prereq 1 prereq 2 ... prereq n
        commands
```

Of course, any Makefile can contain more rules than one. The first rule is called a default rule, and it is conventionally the most general one, also known as final build target. Each rules can be invoked separately, by calling `make target`. If a rule is a prerequisite for another rule, it will be build implicitly by invoking the target that depends on it.

Now, let's look at real world example! I have C program that looks the following way:

#### main.c

```c
#include "print.h"

int main() {
  printInt(42);
}
```

#### print.h

```c
void printInt(int x);
```

#### print.c

```c
#include<stdio.h>

void printInt(int x) {
  printf("%d\n", x);
}
```

Of course, we can just run `gcc *.c`, and get done with it! For the purpose of learning Make, let's build it in a way that you would want to build a bigger project, with more dependencies. First let's compile each of the source files into an object files. For the target `print.o`, prerequisites are `print.h` and `print.c`, and command is `gcc -c print.c` The rule would look like so:

```makefile
print.o: print.c print.h 
         gcc -c print.c  
```

Same can be done for the target `main.o`. Our default rule, I will call it `app`, is going to generate `a.out` binary from compiled object files, which are the prerequisites. Command for the linker is `gcc main.o print.o -o a.out`. This is the rule:

```makefile
app: main.o print.o 
     gcc main.o print.o -o a.out 
```

Make language also allows to use variables. A variable can be defined using assignment sign, and later used by wrapping its name in `$()`. One common case is to define compiler as a variable. Another important note, when you build your project, Make only rebuilds targets, if any of the prerequisites has been updated. It saves some time working with bigger projects.  It is useful to have rules for some other build related tasks, such as "cleaning", or testing your project. 

Finally, the complete Makefile for this tutorial:

```makefile
CC = gcc

app: main.o print.o
     $(CC) main.o print.o -o a.out

main.o: main.c
        $(CC) -c main.c

print.o: print.c print.h
         $(CC) -c print.c

clean:
      rm -f a.out *.o
```