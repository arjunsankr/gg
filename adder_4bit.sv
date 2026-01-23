module adder_4bit(
  input logic[3:0]a,
  input logic[3:0]b,
  input logic cin,
  output logic[3:0]sum,
  output logic cout);

  logic [2:0]c;
 full_adder f1(.a(a[0]),.b(b[0]),.cin(cin),.sum(sum[0]),.cout(c[0])); //first full adder internal connection
 full_adder f2(.a(a[1]),.b(b[1]),.cin(c[0]),.sum(sum[1]),.cout(c[1])); //second full adder internal connection 
 full_adder f3(.a(a[2]),.b(b[2]),.cin(c[1]),.sum(sum[2]),.cout(c[2])); //third full adder internal connection
 full_adder f4(.a(a[3]),.b(b[3]),.cin(c[2]),.sum(sum[3]),.cout(c[3])); //fourth full adder external connection 

endmodule:adder_4bit
