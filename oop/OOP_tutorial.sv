//////////////////////////////////////////////////////////////

//1) Class & object

class vehicle;
    string name;
    int speed;
  
    function new(string name = "car", int speed = 0);
      this.speed = speed;
      this.name = name;
    endfunction
  
    function void display();
      $display("Vehicle: %s, Speed: %0d", name, speed);
    endfunction
  endclass
  
  module test;
    vehicle v1, v2, v3;
  
    initial begin
      v1 = new("Bike", 80);
      v2 = new("Truck", 50);
      v3 = new();
  
      v1.display(); //Bike, 80
      v2.display(); //Truck, 50
      v3.display(); //Car, 0
    end
  endmodule
//oop used are encapsulation: wrapping data members and functions together inside a class

///////////////////////////////////////////////////////////////////////////

//2) Inheritance
//one class can inherit another to add new features or override existing features
  class vehicle;
    string name;
    int speed;
  
    function new(string name = "Car", int speed = 0);
      this.name = name;
      this.speed = speed;
    endfunction
  
    function void display();
        $display("Vehicle: %s, Speed: %0d km/h", name, speed);
    endfunction
  endclass
  
  //car extends vehicle
  class Car extends vehicle;
    int doors;
  
    function new(string name = "Car", int speed = 0, int doors = 4);
      super.new(name, speed);
      this.doors = doors;
    endfunction
  
    function void display();
      $display("Doors: %0d", doors);
    endfunction
  endclass
  
  //creating objects
  module test;
    Car c1;
    vehicle v1;
    initial begin
      c1 = new("sedan", 120, 4);
      v1 = new();
      c1.display();
      v1.display();
    end
  endmodule

///////////////////////////////////////////////////////////////////////////

//Protected data type 

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
///////////////////////////////////////////////////////////////////////////

//using getters and setters to access the protected variables

// Parent class with protected variable and getter/setter
class Parent;
    protected int x = 10; // Protected data member

    // Getter function to access 'x'
    function int get_x();
        return x;
    endfunction

    // Setter function to modify 'x'
    function void set_x(int value);
        this.x = value;
    endfunction
endclass

// Child class that uses getter for accessing 'x'
class Child extends Parent;

    function void display();
        // Accessing protected variable via getter method
        $display("x (using getter) = %0d", get_x());
    endfunction
endclass

module test;
    initial begin
        Child c = new();
       c.set_x(30);
       $display("value of x: %0d", c.get_x());
        c.display();
    end
endmodule
///////////////////////////////////////////////////////////////////////////

//inheritance

class Animal;
    function new();
        $display("Animal Created");
    endfunction
endclass

class Dog extends Animal;
    function new();
        super.new();  // Now the Animal constructor is called
        $display("Dog Created");
    endfunction
endclass

module test;
    initial begin
        Dog d = new();
    end
endmodule

///////////////////////////////////////////////////////////////////////////

//static data members

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

///////////////////////////////////////////////////////////////////////////

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

///////////////////////////////////////////////////////////////////////////

//static function

class math_utils;
    
    // Static function to calculate maximum of two numbers
    static function int max(int a, int b);
        return (a > b) ? a : b;
    endfunction

endclass

// Testbench
module tb;
    initial begin
        int num1 = 25;
        int num2 = 40;

        // Calling static function without object creation
        $display("Maximum Value: %0d", math_utils::max(num1, num2));  // Output: 40

        $finish;
    end
endmodule

///////////////////////////////////////////////////////////////////////////
//static + normal function

class example_class;

    // Static function to calculate square
    static function int square(int num);
        return num * num;
    endfunction

    // Instance variable
    int value;

    // Non-static function to initialize and display
    function void set_value(int v);
        this.value = v;
    endfunction

    // Non-static function to display the stored value
    function void display_value();
        $display("Stored Value (via function): %0d", value);
    endfunction
endclass


module tb;
    example_class obj;  // Non-static object

    initial begin
        int num = 5;

        // Calling static function
        $display("Square of %0d is %0d", num, example_class::square(num));

        // Creating object
        obj = new();

        
        obj.value = 200;   
        $display("Stored Value (via direct access): %0d", obj.value);

        obj.set_value(100); 
        obj.display_value();   

        $finish;
    end
endmodule

////////////////////////////////////////////////////////////////////////////

//4)Encapsulation with protected variable
class BankAccount;
  protected int balance;  // Protected: Can't be accessed outside the class directly

  function new(int initial_balance = 0);
      this.balance = initial_balance;
  endfunction

  // Public method to access private balance
  function void deposit(int amount);
      if (amount > 0) balance += amount;
  endfunction

  function void withdraw(int amount);
      if (amount > 0 && amount <= balance)
          balance -= amount;
      else
          $display("Insufficient Funds!");
  endfunction

  function void display_balance();
      $display("Current Balance: %0d", balance);
  endfunction
endclass

module test;
  BankAccount acc;
  initial begin
      acc = new(1000);
      acc.deposit(500);
      acc.withdraw(300);
      acc.display_balance();  // Output: Current Balance: 1200
  end
endmodule
//balance variable is protected can only be modified via methods.

//protected variable
class BankAccount;
  protected int balance;  // Can only be accessed inside this class & derived classes

  function new(int initial_balance = 0);
      this.balance = initial_balance;
  endfunction
endclass

module test;
  BankAccount acc;
  initial begin
      acc = new(1000);
      acc.balance = 500;  // ERROR: balance is protected and cannot be accessed directly!
  end
endmodule

//using getters and setters for protected variables
class BankAccount;
  protected int balance;  // Only accessible inside class and derived classes

  function new(int initial_balance = 0);
      this.balance = initial_balance;
  endfunction

  function void deposit(int amount);
      this.balance += amount;
  endfunction

  function void withdraw(int amount);
      if (amount > balance)
          $display("Error: Insufficient funds!");
      else
          this.balance -= amount;
  endfunction

  function int get_balance();  //Getter function to access balance safely
      return this.balance;
  endfunction
endclass

module test;
  BankAccount acc;
  initial begin
      acc = new(1000);
      acc.deposit(500);
      acc.withdraw(300);
      
      // Access balance using getter
      $display("Current Balance: %0d", acc.get_balance());  // Correct: Using getter function
  end
endmodule

///////////////////////////////////////////////////////////////////////////////

/*
A base class has an init function and one child class also has an init function. 
What can you do if you want the child class to execute the base class' init function?
*/

class Base;
  function new();
    $display("Base class constructor");
  endfunction
endclass

class Child extends Base;
  function new();
    super.new(); // Calling base class constructor
    $display("Child class constructor");
  endfunction
endclass

/*
Base class constructor  
Child class constructor
*/

//////////////////////////////////////////////////////////////////////////////

