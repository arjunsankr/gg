module full_adder(  //module and variables declaration
  input logic a,    
  input logic b,
  input logic cin,
  output logic sum,
  output logic cout
);

  //full adder logic 
  assign sum=a^b^cin;
  // carry out loigc
  assign cout= (a&b)|(cin&(a^b));  
endmodule:full_adder 
