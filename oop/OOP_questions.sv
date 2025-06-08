//1)
class Counter;
    int count = 0;
    static int total = 0;

    function new();
        count++;
        total++;
    endfunction

    function void display();
        $display("Count: %0d, Total: %0d", count, total);
    endfunction
endclass

module test;
    initial begin
        Counter c1 = new();
        Counter c2 = new();
        Counter c3 = new();
        
        c1.display();
        c2.display();
        c3.display();
    end
endmodule

//expected output 
Count: 1, Total: 3
Count: 1, Total: 3
Count: 1, Total: 3

/////////////////////////////////////////////////////////

//2)
class Vehicle;
    protected string type;
    
    function new(string type);
        this.type = type;
    endfunction
endclass

class Car extends Vehicle;
    function new(string type);
        this.type = type;  
    endfunction
endclass

module test;
    initial begin
        Car c = new("Sedan");
    end
endmodule

//expected 
super.new(type); //inside the new constructor of Car class

/////////////////////////////////////////////////

//3)
class Animal;
    virtual function void makeSound();
        $display("Some generic animal sound!");
    endfunction
endclass

class Dog extends Animal;
    function void makeSound();
        $display("Woof!");
    endfunction
endclass

module test;
    initial begin
        Animal pet;
        pet = new Dog();
        pet.makeSound();  // What will be the output?
    end
endmodule

//output 
//Woof!

//////////////////////////////////////////////////////////

//4)
class Shape;
    pure virtual function void draw();  // ERROR is here!
endclass

class Circle extends Shape;
    function void draw();
        $display("Drawing Circle");
    endfunction
endclass

module test;
    initial begin
        Shape s = new Circle();
        s.draw();
    end
endmodule

//answer
virtual class Shape;
    pure virtual function void draw();
endclass

class Circle extends Shape;
    function void draw();
        $display("Drawing Circle");
    endfunction
endclass

module test;
    initial begin
        Shape s;  // ✅ This is allowed: Creating a handle (pointer)
        s = new Circle();  // ✅ This is allowed: Instantiating a derived class
        s.draw();  // Output: "Drawing Circle"
    end
endmodule

////////////////////////////////////////
class Base;
    static function void show();
        $display("Base Class");
    endfunction
endclass

class Derived extends Base;
    static function void show();
        $display("Derived Class");
    endfunction
endclass

module test;
    initial begin
        Base::show();      // Here we are able to see the displayed messaged because of $display inside the static otherwise we wouldn't have got the message printed
        Derived::show();   //Correct: Directly calling static function from the derived class
    end
endmodule

//answer
//Base Class
//Derived Class

//////////////////////////////////////////////
class Base;
    function void show();
        $display("Base Class");
    endfunction
endclass

class Derived extends Base;
    function void show();
        $display("Derived Class");
    endfunction
endclass

module test;
    initial begin
        Base b = new();
        Derived d = new();

        b.show();  // What will be the output?
        d.show();  // What will be the output?
    end
endmodule

//answer
//Base class
//Derived Class

///////////////////////////////////////////////

class Base;
    virtual function void show();
        $display("Base Class");
    endfunction
endclass

class Derived extends Base;
    function void show();
        $display("Derived Class");
    endfunction
endclass

module test;
    initial begin
        Base b;
        b = new Derived();

        b.show();  // What will be the output?
    end
endmodule

//Answer
//Derived Class

/////////////////////////////////////////////////

class Base;
    function void show();
        $display("Base Class");
    endfunction
endclass

class Derived extends Base;
    function void show();
        $display("Derived Class");
    endfunction
endclass

module test;
    initial begin
        Base b;
        b = new Derived();

        b.show();  // What will be the output now?
    end
endmodule

//Answer
//Base class

/////////////////////////////////////////////

class Parent;
    protected int x = 10;
endclass

class Child extends Parent;
    function void display();
        $display("x = %0d", x);  // Will this work?
    endfunction
endclass

module test;
    initial begin
        Child c = new();
        c.display();
    end
endmodule

//answer

//we need to use this.x to access the protected variable inside the child
class Parent;
    protected int x = 10;
endclass

class Child extends Parent;
    function void display();
        $display("x = %0d", this.x);  // ✅ Correct: Use `this.x` to avoid name conflict between local and inherited value
    endfunction
endclass

module test;
    initial begin
        Child c = new();
        c.display();  // ✅ Expected output: "x = 10"
    end
endmodule

/////////////////////////////////////////////////

class A;
    static int count = 0;

    function new();
        count++;
    endfunction
endclass

module test;
    initial begin
        A a1 = new();
        A a2 = new();
        A a3 = new();

        $display("Total instances: %0d", A::count);
    end
endmodule

//answer 
//3

//////////////////////////////////////////////////

//interesting

class A;
    static int count = 0;

    function new();
        count++;
    endfunction
endclass

class B extends A;
    function new();
        super.new();
        count++;
    endfunction
endclass

module test;
    initial begin
        A a1 = new();
        B b1 = new();
        B b2 = new();

        $display("Total count: %0d", A::count);
    end
endmodule

//answer : 4, because in each B b1 = new() count increments twice but you display A::count thats why one less in the last case

/////////////////////////////////////////////////////

class Animal;
    function new();
        $display("Animal Created");
    endfunction
endclass

class Dog extends Animal;
    function new();
        super.new();  // ✅ Now the Animal constructor is called
        $display("Dog Created");
    endfunction
endclass

module test;
    initial begin
        Dog d = new();
    end
endmodule

//Answer
//Animal Created
//Dog Created

////////////////////////////////////////////////////////
class Base;
    static int count = 0;

    function new();
        count++;
        $display("Count = %0d", count);
    endfunction
endclass

module test;
    initial begin
        Base b1 = new();
        Base b2 = new();
        Base b3 = new();

        $display("Final count: %0d", Base::count);
    end
endmodule
//answer
// Count = 1
// Count = 2
// Count = 3
// Final count: 3

///////////////////////////////////////////////////////

class Shape; //abstract classes should have virtual key in their name
    pure virtual function void draw();
endclass

class Circle extends Shape;
endclass

module test;
    initial begin
        Shape s = new Circle();
        s.draw();
    end
endmodule

//Answer
virtual class Shape;  // ✅ Explicitly mark as `virtual`
    pure virtual function void draw();  // ✅ Must be implemented by derived classes
endclass

class Circle extends Shape;
    function void draw();
        $display("Drawing Circle");
    endfunction
endclass

module test;
    initial begin
        Circle c = new();
        Shape s = c;
        s.draw();
    end
endmodule

/////////////////////////////////////////////////////
//Polymorphism
// base class 
class base_class;
    function void display();
      $display("Inside base class");
    endfunction
  endclass
  
  // extended class 1
  class ext_class_1 extends base_class;
     function void display();
      $display("Inside extended class 1");
    endfunction
  endclass
  
  // extended class 2
  class ext_class_2 extends base_class;
     function void display();
      $display("Inside extended class 2");
    endfunction
  endclass
  
  // extended class 3
  class ext_class_3 extends base_class;
   function void display();
      $display("Inside extended class 3");
    endfunction
  endclass

  module class_polymorphism;

    initial begin 
      
      //declare and create extended class
      ext_class_1 ec_1 = new();
      ext_class_2 ec_2 = new();
      ext_class_3 ec_3 = new();
      
      //base class handle
      base_class b_c[3];
      
      //assigning extended class to base class
      b_c[0] = ec_1;
      b_c[1] = ec_2;
      b_c[2] = ec_3;
      
      //accessing extended class methods using base class handle
      b_c[0].display();
      b_c[1].display();
      b_c[2].display();
    end
  
  endmodule