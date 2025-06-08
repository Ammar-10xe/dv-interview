// 1. Explain how polymorphism is used in UVM.

// Definition

// Polymorphism allows an object to be treated as its base type while executing the derived class’s methods. It enables flexible testbench components, as sequences, transactions, or components can be dynamically swapped without modifying the testbench structure.

// Example: Polymorphism in UVM
// 	•	Suppose we have a base transaction class and multiple derived transaction classes.
// 	•	Using polymorphism, we can store both read and write transactions in a common handle.

class base_transaction extends uvm_sequence_item;
    rand bit [7:0] addr;
    rand bit [31:0] data;
    
    `uvm_object_utils(base_transaction)
  
    virtual function void display();
      `uvm_info("BASE", "Base Transaction", UVM_MEDIUM)
    endfunction
endclass
  
class read_transaction extends base_transaction;
    `uvm_object_utils(read_transaction)
  
    function new(string name = "read_transaction");
      super.new(name);
    endfunction
  
    virtual function void display();
      `uvm_info("READ", $sformatf("Read Addr: %h", addr), UVM_MEDIUM)
    endfunction
endclass
  
class write_transaction extends base_transaction;
    `uvm_object_utils(write_transaction)
  
    function new(string name = "write_transaction");
      super.new(name);
    endfunction
  
    virtual function void display();
      `uvm_info("WRITE", $sformatf("Write Addr: %h, Data: %h", addr, data), UVM_MEDIUM)
    endfunction
endclass
  
  // Example Usage
module test;
    base_transaction tr; // Base class handle
  
    initial begin
      tr = new read_transaction();  // Polymorphism in action
      tr.display(); // Calls ReadTransaction’s display()
  
      tr = new write_transaction();
      tr.display(); // Calls WriteTransaction’s display()
    end
endmodule

//   Why is this useful?
//   •	We can use a base transaction handle to dynamically store different transaction types.
//   •	Enables reusability and flexibility in UVM testbenches.


//2.  What is encapsulation in SystemVerilog? How does it improve a UVM testbench?
//You’re correct! Encapsulation in SystemVerilog allows us to bundle data and methods together while restricting access using protected or local keywords. This prevents accidental modifications and enforces controlled access.
  class transaction;
    protected rand bit [7:0] addr; // Protected member (cannot be accessed directly)
  
    `uvm_object_utils(transaction)
  
    // Constructor
    function new(string name = "transaction");
      addr = 8'h00; // Default value
    endfunction
  
    // Setter method (Controlled access)
    function void set_addr(bit [7:0] new_addr);
      addr = new_addr;
    endfunction
  
    // Getter method (Controlled access)
    function bit [7:0] get_addr();
      return addr;
    endfunction
  
    // Display function
    function void display();
      `uvm_info("TRANSACTION", $sformatf("Transaction Address: %h", addr), UVM_MEDIUM)
    endfunction
  endclass
  
  // Test module
  module test;
    transaction tr;
  
    initial begin
      tr = new();
      
      // Setting the value using a method
      tr.set_addr(8'hAA);
      
      // Getting the value using a method
      $display("Address: %h", tr.get_addr());
  
      // Attempting to access addr directly (Will cause an error)
      // tr.addr = 8'hBB; // ERROR: addr is protected!
  
      tr.display();
    end
  endmodule


  //3.What is virtual in SystemVerilog and Why is it Used in UVM?
//   Definition of virtual
// 	•	The virtual keyword in SystemVerilog is used for method overriding and polymorphism.
// 	•	It allows late binding, meaning the function to be executed is determined at runtime instead of compile-time.
// 	•	virtual is required when we want to override a base class function in a derived class while ensuring that the function in the base class can still be accessed dynamically.

  //If display() in BaseTransaction is not virtual, the base class method would always be executed, even when a derived class object is assigned.


// 4. What is Registering a Class to a Factory in UVM?

// Registering a class to the UVM factory allows UVM to dynamically create objects at runtime. This is essential for object replacement, reusability, and factory pattern-based overrides.
// Why Do We Need to Register Classes to the Factory?
// 	1.	Dynamic Object Creation
// 	•	Instead of using new(), UVM uses create() to create objects dynamically.
// 	2.	Runtime Object Replacement (Overrides)
// 	•	The factory allows replacing a base class with a derived class without modifying the testbench code.
// 	3.	Factory Pattern Enables Scalability
// 	•	New transaction types, sequences, and components can be added without modifying existing code.


//   5.Next Question: How can you replace a base test with a derived test dynamically in UVM without changing the testbench code?
//   By using UVM factory override
  class base_test extends uvm_test;
    `uvm_component_utils(base_test)
  
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  
    virtual function void build_phase(uvm_phase phase);
      `uvm_info("BASE_TEST", "Building base test environment", UVM_MEDIUM)
    endfunction
  endclass

  class extended_test extends base_test;
    `uvm_component_utils(extended_test)
  
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  
    virtual function void build_phase(uvm_phase phase);
      `uvm_info("EXTENDED_TEST", "Building extended test environment", UVM_MEDIUM)
    endfunction
  endclass

  module test;
    initial begin
        base_test::type_id::set_type_override(extended_test::get_type());
        run_test("base_test");
    end
endmodule


/////////////////////////////////////////////////////////////////////////////

//SystemVerilog OOP
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

/////////////////////////////////////////////////////////////////////////////


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


/////////////////////////////////////////////////////////////////////////////


//3)polymorphism 
//Many forms, we can create a handle of two types and the correct method is called at the runtime'
class Vehicle;
  virtual function void drive();
      $display("Driving a generic vehicle.");
  endfunction
endclass

class Car extends Vehicle;
  function void drive();
      $display("Driving a car!");
  endfunction
endclass

class Bike extends Vehicle;
  function void drive();
      $display("Riding a bike!");
  endfunction
endclass

module test;
  Vehicle v;
  v = new Car();
  v.drive(); //Driving a car!

  v = new Bike();
  v.drive(); //Riding a bike
endmodule
//polymorphism: drive() is overridden in different child classes (Car, Bike)

/////////////////////////////////////////////////////////////////////////////


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



/////////////////////////////////////////////////////////////////////////////

//static functions
class MathUtil;
  static function int square(int x);
      return x * x;
  endfunction
endclass

module test;
  initial begin
      int result = MathUtil::square(5);  // ✅ No need to create an object
      $display("Square of 5: %0d", result);
  end
endmodule

//another method 
class MathUtil;
  static function int square(int x);
      return x * x;
  endfunction
endclass

module test;
  MathUtil handle;  // Creating a handle for the class

  initial begin
      handle = new();  // Creating an object (not needed for static functions)
      
      int result1 = MathUtil::square(5);   // Correct way (Calling via class name)
      int result2 = handle.square(6);      // Works but NOT recommended

      $display("Square via class name: %0d", result1);
      $display("Square via handle: %0d", result2);
  end
endmodule

//more static examples
class Counter;
  int count;         // ❌ Instance variable (non-static)
  static int total;  // ✅ Static variable (shared across all instances)

  static function void show();
      $display("Total: %0d", total);  // ✅ Allowed: Accessing static variable
      $display("Count: %0d", count);  // ❌ ERROR: Static function cannot access instance variables!
  endfunction
endclass

module test;
  initial begin
      Counter::show();
  end
endmodule

//another example

class Counter;
  int count;         // ✅ Instance variable
  static int total;  // ✅ Static variable (shared across all objects)

  function void increment();
      count++;        // ✅ Allowed: Accessing instance variable
      total++;        // ✅ Allowed: Static variables can be updated by instance methods
  endfunction

  static function void show();
      $display("Total: %0d", total);  // ✅ Allowed: Accessing static variable
  endfunction
endclass

module test;
  Counter c1, c2;
  initial begin
      c1 = new();
      c2 = new();

      c1.increment();
      c2.increment();
      c2.increment();

      Counter::show();  // ✅ Correct: Accessing static function via class
      //value of total is 2 since it is shared across all the instances not specific to instance
  end
endmodule

/////////////////////////////////////////////////////////////////////////////
//protected

class Base;
  protected int value = 10;  // ✅ Only accessible in Base & derived classes
endclass

class Derived extends Base;
  function void show();
      $display("Value: %0d", value);  // ✅ Allowed: Derived class can access protected members
  endfunction
endclass

module test;
  initial begin
      Derived d = new();
      $display("Accessing from main: %0d", d.value);  // ❌ ERROR: Protected members cannot be accessed outside class hierarchy!
  end
endmodule

//correct way to get the value of protected variable

class Base;
  protected int value = 10;

  function int getValue();  // ✅ Public function to access protected variable
      return value;
  endfunction
endclass

class Derived extends Base;
  function void show();
      $display("Value: %0d", getValue());  // ✅ Correct: Accessing via getter
  endfunction
endclass

module test;
  initial begin
      Derived d = new();
      $display("Accessing from main: %0d", d.getValue());  // ✅ Correct: Using getter
  end
endmodule


/////////////////////////////////////////////////////////////////////////////

///
class example_class;

  // Static data member (shared among all objects)
  static int total_objects = 0;

  // Non-static data member (unique per object)
  int instance_id;

  // Static function (can only access static variables)
  static function void increment_objects();
      total_objects++;
  endfunction

  // Non-static function (can access both static & non-static variables)
  function void set_id(int id);
      this.instance_id = id;
      increment_objects();  // Calling static function inside non-static function
  endfunction

  // Non-static function to display details
  function void display_info();
      $display("Instance ID: %0d | Total Objects Created: %0d", instance_id, total_objects);
  endfunction
endclass

// Testbench
module tb;
  example_class obj1, obj2;

  initial begin
      // Creating first object
      obj1 = new();
      obj1.set_id(101);
      obj1.display_info();

      // Creating second object
      obj2 = new();
      obj2.set_id(202);
      obj2.display_info();

      // Accessing the static variable directly via class name
      $display("Total Objects (via static variable): %0d", example_class::total_objects);

      $finish;
  end
endmodule